--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

package body Test_Init is

   procedure Test_Basic_Init (Op : in out Trendy_Test.Operation'Class) is
   begin
      Op.Register (Parallelize => False);

      Op.Assert (3 > 1);
   end Test_Basic_Init;

end Test_Init;
