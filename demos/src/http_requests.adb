--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

pragma Ada_2022;

with Ada.Streams;
with GNAT.Sockets;
with VSS.Characters;
with VSS.String_Vectors;
with VSS.Strings.Conversions;
with VSS.Strings.Formatters.Generic_Integers;
with VSS.Strings.Templates;
with VSS.Text_Streams.Memory_UTF8_Input;
with VSS.Text_Streams.Memory_UTF8_Output;
with VSS.Transformers.Casing;

package body HTTP_Requests is

   ----------
   -- Post --
   ----------

   overriding
   procedure Post
     (Self          : in out HTTP_Request;
      URL           : VSS.IRIs.IRI;
      Content_Type  : VSS.Strings.Virtual_String;
      Authorization : VSS.Strings.Virtual_String;
      Output        : VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Response      : out VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Status_Code   : out Natural)
   is
      use all type GNAT.Sockets.Family_Type;
      use all type VSS.Strings.Virtual_String;

      procedure Send_Element_Vector
        (Socket : GNAT.Sockets.Socket_Type;
         Data   : VSS.Stream_Element_Vectors.Stream_Element_Vector);

      procedure To_String_List
        (Data   : in out VSS.Stream_Element_Vectors.Stream_Element_Vector;
         Result : out VSS.String_Vectors.Virtual_String_Vector);

      function Get_Content_Length
        (Header : VSS.String_Vectors.Virtual_String_Vector)
         return Ada.Streams.Stream_Element_Offset;

      ------------------------
      -- Get_Content_Length --
      ------------------------

      function Get_Content_Length
        (Header : VSS.String_Vectors.Virtual_String_Vector)
         return Ada.Streams.Stream_Element_Offset is
      begin
         for Line of Header when Line.Starts_With ("content-length: ") loop
            declare
               Text : constant String :=
                 VSS.Strings.Conversions.To_UTF_8_String (Line);
            begin
               return
                 Ada.Streams.Stream_Element_Offset'Value
                   (Text (16 .. Text'Last));
            end;
         end loop;

         return 0;
      end Get_Content_Length;

      --------------------
      -- To_String_List --
      --------------------

      procedure To_String_List
        (Data   : in out VSS.Stream_Element_Vectors.Stream_Element_Vector;
         Result : out VSS.String_Vectors.Virtual_String_Vector)
      is
         Empty : VSS.Stream_Element_Vectors.Stream_Element_Vector;
         Input : VSS.Text_Streams.Memory_UTF8_Input.Memory_UTF8_Input_Stream;
         Text  : VSS.Strings.Virtual_String;
         Ok    : Boolean := True;
         Item  : VSS.Characters.Virtual_Character;
      begin
         Input.Set_Data (Data);

         while not Input.Is_End_Of_Stream loop
            Input.Get (Item, Ok);
            exit when not Ok;
            Text.Append (Item);
         end loop;

         VSS.Transformers.Casing.To_Lowercase.Transform (Text);
         Result := Text.Split_Lines;
         Data := Empty;
      end To_String_List;

      -------------------------
      -- Send_Element_Vector --
      -------------------------

      procedure Send_Element_Vector
        (Socket : GNAT.Sockets.Socket_Type;
         Data   : VSS.Stream_Element_Vectors.Stream_Element_Vector)
      is
         use type Ada.Streams.Stream_Element_Offset;
         Last   : Ada.Streams.Stream_Element_Offset := Data.Length;
         Buffer : Ada.Streams.Stream_Element_Array (1 .. Last);
      begin
         for J in Buffer'Range loop
            Buffer (J) := Data (J);
         end loop;

         GNAT.Sockets.Send_Socket (Socket, Buffer, Last);
         pragma Assert (Last = Buffer'Last);
      end Send_Element_Vector;

      Socket   : GNAT.Sockets.Socket_Type;
      URL_Host : VSS.Strings.Virtual_String;
      URL_Path : VSS.Strings.Virtual_String;
      URL_Port : GNAT.Sockets.Port_Type := 80;
      Address  : GNAT.Sockets.Sock_Addr_Type;

   begin
      declare
         List : constant VSS.String_Vectors.Virtual_String_Vector :=
           URL.To_Virtual_String.Split ('/');
         --  http://localhost:8080/v1/chat/completions ->
         --   ["http:", "", "localhost:8080", "v1", "chat", "completions"]

         Name : constant VSS.String_Vectors.Virtual_String_Vector :=
           List (3).Split (':');

         Host : constant GNAT.Sockets.Host_Entry_Type :=
           GNAT.Sockets.Get_Host_By_Name
             (VSS.Strings.Conversions.To_UTF_8_String (Name (1)));
      begin
         URL_Path := List.Slice (4, List.Length).Join ("/");
         URL_Host := List (3);

         if GNAT.Sockets.Addresses (Host, 1).Family = Family_Inet6 then
            Address := (Family => Family_Inet6, others => <>);
         end if;

         Address.Addr := GNAT.Sockets.Addresses (Host, 1);

         if Name.Length > 1 then
            URL_Port :=
              GNAT.Sockets.Port_Type'Value
                (VSS.Strings.Conversions.To_UTF_8_String (Name (2)));

            Address.Port := URL_Port;
         end if;
      end;

      GNAT.Sockets.Create_Socket (Socket);
      GNAT.Sockets.Connect_Socket (Socket, Address);

      declare
         package Offset_Formatters is new
           VSS.Strings.Formatters.Generic_Integers
             (Ada.Streams.Stream_Element_Offset);

         Content_Length :
           constant VSS.Strings.Templates.Virtual_String_Template :=
             "Content-Length: {}";

         Header : constant VSS.String_Vectors.Virtual_String_Vector :=
           ["POST /" & URL_Path & " HTTP/1.1",
            "Host: " & URL_Host,
            "Content-Type: " & Content_Type,
            Content_Length.Format (Offset_Formatters.Image (Output.Length)),
            "Authorization: " & Authorization,
            ""];

         Prefix :
           VSS.Text_Streams.Memory_UTF8_Output.Memory_UTF8_Output_Stream;

         Success : Boolean := True;

      begin
         Prefix.Put (Header.Join_Lines (VSS.Strings.CRLF), Success);
         pragma Assert (Success);

         Send_Element_Vector (Socket, Prefix.Buffer);
         Send_Element_Vector (Socket, Output);
      end;

      declare
         use type Ada.Streams.Stream_Element;
         use type Ada.Streams.Stream_Element_Offset;

         EOL    : Natural := 0;
         Header : VSS.String_Vectors.Virtual_String_Vector;
         Buffer : Ada.Streams.Stream_Element_Array (1 .. 1024);
         Last   : Ada.Streams.Stream_Element_Offset;
         Size   : Ada.Streams.Stream_Element_Offset := Buffer'Length;
      begin
         while Size > 0 loop
            Last := Ada.Streams.Stream_Element_Offset'Min (Size, Buffer'Last);

            GNAT.Sockets.Receive_Socket (Socket, Buffer (1 .. Last), Last);
            exit when Last < Buffer'First;

            for J in 1 .. Last loop
               Response.Append (Buffer (J));

               if EOL >= 4 then
                  Size := @ - 1;
                  exit when Size = 0;
               elsif Buffer (J) = (if EOL mod 2 = 0 then 13 else 10) then
                  EOL := EOL + 1;

                  if EOL = 4 then
                     To_String_List (Response, Header);
                     Size := Get_Content_Length (Header);
                     Response.Set_Capacity (Size);
                  end if;
               elsif EOL in 1 .. 3 then
                  EOL := 0;
               end if;
            end loop;
         end loop;
      end;

      --  A minimal demo client: doesn't actually parse the HTTP status
      --  line, so an error response body (with an appropriate JSON parse
      --  failure) is the only sign something went wrong.
      Status_Code := 200;
      GNAT.Sockets.Close_Socket (Socket);
   end Post;
end HTTP_Requests;
