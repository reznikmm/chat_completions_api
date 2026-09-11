--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
------------------------------------------------------------------

with VSS.IRIs;
with VSS.Strings;
with VSS.Stream_Element_Vectors;

with Chat_Completions_API.HTTP_Requests;

package HTTP_Requests is

   type HTTP_Request is limited
     new Chat_Completions_API.HTTP_Requests.HTTP_Request
   with null record;

   overriding
   procedure Post
     (Self          : in out HTTP_Request;
      URL           : VSS.IRIs.IRI;
      Content_Type  : VSS.Strings.Virtual_String;
      Authorization : VSS.Strings.Virtual_String;
      Output        : VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Response      : out VSS.Stream_Element_Vectors.Stream_Element_Vector;
      Status_Code   : out Natural);

end HTTP_Requests;
