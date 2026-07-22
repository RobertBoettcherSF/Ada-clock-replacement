with Clock_Algorithms; use Clock_Algorithms;
with Ada.Text_IO; use Ada.Text_IO;

procedure Debug_Test is
   -- Test the Clock algorithm with sequence (1,2,3,4,1,2,5,1,2,3)
   Algo : Clock_Algo := Init_Clock(3);
   Pages : constant array(1..10) of Page_ID := (1, 2, 3, 4, 1, 2, 5, 1, 2, 3);
begin
   Put_Line("Clock Algorithm Trace (Capacity=3):");
   for P of Pages loop
      Put("Access page " & Page_ID'Image(P) & " -> ");
      Access_Page(Algo, P);
      Put_Line("Faults: " & Natural'Image(Get_Page_Faults(Algo)) & 
               ", Hits: " & Natural'Image(Algo.Accesses - Algo.Page_Faults));
   end loop;
   Put_Line("Final: Faults=" & Natural'Image(Get_Page_Faults(Algo)) & 
            ", Hit Rate=" & Float'Image(Get_Hit_Rate(Algo)));
   New_Line;
   
   -- Test GCLOCK with same sequence
   declare
      Algo2 : GCLOCK_Algo := Init_GCLOCK(3, 2);
   begin
      Put_Line("GCLOCK Algorithm Trace (Capacity=3, Max_Count=2):");
      for P of Pages loop
         Put("Access page " & Page_ID'Image(P) & " -> ");
         Access_Page(Algo2, P);
         Put_Line("Faults: " & Natural'Image(Get_Page_Faults(Algo2)) & 
                  ", Hits: " & Natural'Image(Algo2.Accesses - Algo2.Page_Faults));
      end loop;
      Put_Line("Final: Faults=" & Natural'Image(Get_Page_Faults(Algo2)) & 
               ", Hit Rate=" & Float'Image(Get_Hit_Rate(Algo2)));
   end;
end Debug_Test;
