--
--  Copyright (c) 2026, OpenAI
--
--  SPDX-License-Identifier: MIT
--

pragma Style_Checks ("M99");  --  suppress style warning unitl gnatpp is fixed
with Ada.Unchecked_Deallocation;

package body Chat_Completions_API.Types is
   procedure Free is new
     Ada.Unchecked_Deallocation
       (ChatCompletionChoice_Array,
        ChatCompletionChoice_Array_Access);

   overriding
   procedure Adjust (Self : in out ChatCompletionChoice_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data :=
           new ChatCompletionChoice_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ChatCompletionChoice_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ChatCompletionChoice_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ChatCompletionChoice_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ChatCompletionChoice_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out ChatCompletionChoice_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self : in out ChatCompletionChoice_Vector; Value : ChatCompletionChoice)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ChatCompletionChoice'Size);
      Self_Data_Saved : ChatCompletionChoice_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ChatCompletionChoice_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data :=
           new ChatCompletionChoice_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ChatCompletionChoice_Variable_Reference
     (Self : aliased in out ChatCompletionChoice_Vector; Index : Positive)
      return ChatCompletionChoice_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ChatCompletionChoice_Constant_Reference
     (Self : aliased ChatCompletionChoice_Vector; Index : Positive)
      return ChatCompletionChoice_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (ChatCompletionMessageToolCall_Array,
        ChatCompletionMessageToolCall_Array_Access);

   overriding
   procedure Adjust (Self : in out ChatCompletionMessageToolCall_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data :=
           new ChatCompletionMessageToolCall_Array'
             (Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ChatCompletionMessageToolCall_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ChatCompletionMessageToolCall_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null
     (Self : ChatCompletionMessageToolCall_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ChatCompletionMessageToolCall_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self    : in out ChatCompletionMessageToolCall_Vector;
      Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self  : in out ChatCompletionMessageToolCall_Vector;
      Value : ChatCompletionMessageToolCall)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ChatCompletionMessageToolCall'Size);
      Self_Data_Saved : ChatCompletionMessageToolCall_Array_Access :=
        Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data :=
           new ChatCompletionMessageToolCall_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data :=
           new ChatCompletionMessageToolCall_Array
                 (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ChatCompletionMessageToolCall_Variable_Reference
     (Self  : aliased in out ChatCompletionMessageToolCall_Vector;
      Index : Positive) return ChatCompletionMessageToolCall_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ChatCompletionMessageToolCall_Constant_Reference
     (Self : aliased ChatCompletionMessageToolCall_Vector; Index : Positive)
      return ChatCompletionMessageToolCall_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (ChatCompletionTokenLogprob_Array,
        ChatCompletionTokenLogprob_Array_Access);

   overriding
   procedure Adjust (Self : in out ChatCompletionTokenLogprob_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data :=
           new ChatCompletionTokenLogprob_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ChatCompletionTokenLogprob_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ChatCompletionTokenLogprob_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ChatCompletionTokenLogprob_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ChatCompletionTokenLogprob_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self    : in out ChatCompletionTokenLogprob_Vector;
      Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self  : in out ChatCompletionTokenLogprob_Vector;
      Value : ChatCompletionTokenLogprob)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ChatCompletionTokenLogprob'Size);
      Self_Data_Saved : ChatCompletionTokenLogprob_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ChatCompletionTokenLogprob_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data :=
           new ChatCompletionTokenLogprob_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ChatCompletionTokenLogprob_Variable_Reference
     (Self  : aliased in out ChatCompletionTokenLogprob_Vector;
      Index : Positive) return ChatCompletionTokenLogprob_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ChatCompletionTokenLogprob_Constant_Reference
     (Self : aliased ChatCompletionTokenLogprob_Vector; Index : Positive)
      return ChatCompletionTokenLogprob_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (ChatCompletionRequestMessage_Array,
        ChatCompletionRequestMessage_Array_Access);

   overriding
   procedure Adjust (Self : in out ChatCompletionRequestMessage_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data :=
           new ChatCompletionRequestMessage_Array'
             (Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ChatCompletionRequestMessage_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ChatCompletionRequestMessage_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ChatCompletionRequestMessage_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ChatCompletionRequestMessage_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self    : in out ChatCompletionRequestMessage_Vector;
      Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self  : in out ChatCompletionRequestMessage_Vector;
      Value : ChatCompletionRequestMessage)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ChatCompletionRequestMessage'Size);
      Self_Data_Saved : ChatCompletionRequestMessage_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data :=
           new ChatCompletionRequestMessage_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data :=
           new ChatCompletionRequestMessage_Array
                 (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ChatCompletionRequestMessage_Variable_Reference
     (Self  : aliased in out ChatCompletionRequestMessage_Vector;
      Index : Positive) return ChatCompletionRequestMessage_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ChatCompletionRequestMessage_Constant_Reference
     (Self : aliased ChatCompletionRequestMessage_Vector; Index : Positive)
      return ChatCompletionRequestMessage_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation
       (ChatCompletionTool_Array,
        ChatCompletionTool_Array_Access);

   overriding
   procedure Adjust (Self : in out ChatCompletionTool_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data :=
           new ChatCompletionTool_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out ChatCompletionTool_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return ChatCompletionTool_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : ChatCompletionTool_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : ChatCompletionTool_Vector) return Natural
   is (Self.Length);

   procedure Clear
     (Self : in out ChatCompletionTool_Vector; Is_Null : Boolean := True) is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append
     (Self : in out ChatCompletionTool_Vector; Value : ChatCompletionTool)
   is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / ChatCompletionTool'Size);
      Self_Data_Saved : ChatCompletionTool_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new ChatCompletionTool_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data :=
           new ChatCompletionTool_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_ChatCompletionTool_Variable_Reference
     (Self : aliased in out ChatCompletionTool_Vector; Index : Positive)
      return ChatCompletionTool_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_ChatCompletionTool_Constant_Reference
     (Self : aliased ChatCompletionTool_Vector; Index : Positive)
      return ChatCompletionTool_Constant_Reference
   is (Element => Self.Data (Index)'Access);

   procedure Free is new
     Ada.Unchecked_Deallocation (Integer_64_Array, Integer_64_Array_Access);

   overriding
   procedure Adjust (Self : in out Integer_64_Vector) is
   begin
      if Self.Length > 0 then
         Self.Data := new Integer_64_Array'(Self.Data (1 .. Self.Length));
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out Integer_64_Vector) is
   begin
      Free (Self.Data);
      Self.Length := 0;
   end Finalize;

   function Empty return Integer_64_Vector
   is (Ada.Finalization.Controlled with others => <>);

   function Is_Null (Self : Integer_64_Vector) return Boolean
   is (Self.Is_Null);

   function Length (Self : Integer_64_Vector) return Natural
   is (Self.Length);

   procedure Clear (Self : in out Integer_64_Vector; Is_Null : Boolean := True)
   is
   begin
      Self.Length := 0;
      Self.Is_Null := Is_Null;
   end Clear;

   procedure Append (Self : in out Integer_64_Vector; Value : Integer_64) is
      Init_Length     : constant Positive :=
        Positive'Max (2, 256 / Integer_64'Size);
      Self_Data_Saved : Integer_64_Array_Access := Self.Data;
   begin
      if Self.Length = 0 then
         Self.Is_Null := False;
         Self.Data := new Integer_64_Array (1 .. Init_Length);
      elsif Self.Length = Self.Data'Last then
         Self.Data := new Integer_64_Array (1 .. 3 * Self.Length / 2 + 1);
         Self.Data (1 .. Self.Length) := Self_Data_Saved.all;
         Free (Self_Data_Saved);
      end if;
      Self.Length := Self.Length + 1;
      Self.Data (Self.Length) := Value;
   end Append;

   not overriding
   function Get_Integer_64_Variable_Reference
     (Self : aliased in out Integer_64_Vector; Index : Positive)
      return Integer_64_Variable_Reference
   is (Element => Self.Data (Index)'Access);

   not overriding
   function Get_Integer_64_Constant_Reference
     (Self : aliased Integer_64_Vector; Index : Positive)
      return Integer_64_Constant_Reference
   is (Element => Self.Data (Index)'Access);

end Chat_Completions_API.Types;
