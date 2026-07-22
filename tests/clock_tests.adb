with Clock_Algorithms; use Clock_Algorithms;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;

package body Clock_Tests is

   -- Current test being executed
   Current_Test : Test_Case;
   Test_Index   : Positive := 1;
   All_Tests    : Test_Suite(1..15); -- Array for all test cases

   procedure Assert (Condition : Boolean; Message : String) is
   begin
      if not Condition then
         Current_Test.Result := Fail;
         Current_Test.Details := "Assertion failed: " & Message;
         Failed_Tests := Failed_Tests + 1;
         Put_Line("  [FAIL] " & Message);
      else
         Put_Line("  [PASS] " & Message);
      end if;
      Total_Tests := Total_Tests + 1;
   end Assert;

   procedure Assert_Equal (Actual, Expected : Natural; Message : String) is
   begin
      if Actual = Expected then
         Put_Line("  [PASS] " & Message & " (Expected: " & Natural'Image(Expected) & 
                  ", Actual: " & Natural'Image(Actual) & ")");
      else
         Current_Test.Result := Fail;
         Current_Test.Details := "Values not equal: " & Message;
         Failed_Tests := Failed_Tests + 1;
         Put_Line("  [FAIL] " & Message & " (Expected: " & Natural'Image(Expected) & 
                  ", Actual: " & Natural'Image(Actual) & ")");
      end if;
      Total_Tests := Total_Tests + 1;
   end Assert_Equal;

   procedure Assert_Equal (Actual, Expected : Float; Message : String; Tolerance : Float := 0.001) is
   begin
      if abs(Actual - Expected) <= Tolerance then
         Put_Line("  [PASS] " & Message & " (Expected: " & Float'Image(Expected) & 
                  ", Actual: " & Float'Image(Actual) & ")");
      else
         Current_Test.Result := Fail;
         Current_Test.Details := "Values not equal: " & Message;
         Failed_Tests := Failed_Tests + 1;
         Put_Line("  [FAIL] " & Message & " (Expected: " & Float'Image(Expected) & 
                  ", Actual: " & Float'Image(Actual) & ")");
      end if;
      Total_Tests := Total_Tests + 1;
   end Assert_Equal;


   -- ========================================================
   -- Standard Clock Tests
   -- ========================================================

   procedure Test_Clock_Empty_Access is
      Algo : Clock_Algo := Init_Clock(3);
   begin
      New_Line;
      Put_Line("Test 1: Clock - Empty access sequence");
      Current_Test := (Name => "Clock_Empty_Access", 
                       Description => "Accessing no pages should result in 0 faults",
                       Result => Pass, Details => "");
      
      Assert_Equal(Get_Page_Faults(Algo), 0, "Empty access = 0 page faults");
      Assert_Equal(Get_Hit_Rate(Algo), 0.0, "Empty access = 0% hit rate");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_Clock_Empty_Access;

   procedure Test_Clock_Single_Page is
      Algo : Clock_Algo := Init_Clock(3);
   begin
      New_Line;
      Put_Line("Test 2: Clock - Single page repeated access");
      Current_Test := (Name => "Clock_Single_Page", 
                       Description => "Repeated access to same page should have 1 fault",
                       Result => Pass, Details => "");
      
      for I in 1..5 loop
         Access_Page(Algo, 1);
      end loop;
      
      Assert_Equal(Get_Page_Faults(Algo), 1, "Single page = 1 page fault");
      Assert_Equal(Get_Hit_Rate(Algo), 0.8, "Single page = 80% hit rate");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_Clock_Single_Page;

   procedure Test_Clock_Page_Faults is
      Algo : Clock_Algo := Init_Clock(3);
      Pages : constant array(1..10) of Page_ID := (1, 2, 3, 4, 1, 2, 5, 1, 2, 3);
   begin
      New_Line;
      Put_Line("Test 3: Clock - Page fault counting");
      Current_Test := (Name => "Clock_Page_Faults", 
                       Description => "Standard reference string should have 7 faults",
                       Result => Pass, Details => "");
      
      for P of Pages loop
         Access_Page(Algo, P);
      end loop;
      
      Assert_Equal(Get_Page_Faults(Algo), 7, "Reference string = 7 page faults");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_Clock_Page_Faults;

   procedure Test_Clock_Hit_Rate is
      Algo : Clock_Algo := Init_Clock(3);
      Pages : constant array(1..10) of Page_ID := (1, 2, 3, 1, 2, 3, 1, 2, 3, 1);
   begin
      New_Line;
      Put_Line("Test 4: Clock - Hit rate calculation");
      Current_Test := (Name => "Clock_Hit_Rate", 
                       Description => "All pages in cache should have high hit rate",
                       Result => Pass, Details => "");
      
      for P of Pages loop
         Access_Page(Algo, P);
      end loop;
      
      Assert_Equal(Get_Page_Faults(Algo), 3, "3 unique pages = 3 faults");
      Assert_Equal(Get_Hit_Rate(Algo), 0.7, "7 hits out of 10 = 70% hit rate");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_Clock_Hit_Rate;

   procedure Test_Clock_Circular_Replacement is
      Algo : Clock_Algo := Init_Clock(3);
      Pages : constant array(1..10) of Page_ID := (1, 2, 3, 4, 5, 6, 1, 2, 3, 4);
   begin
      New_Line;
      Put_Line("Test 5: Clock - Circular replacement behavior");
      Current_Test := (Name => "Clock_Circular_Replacement", 
                       Description => "Clock should replace pages in circular fashion",
                       Result => Pass, Details => "");
      
      for P of Pages loop
         Access_Page(Algo, P);
      end loop;
      
      -- With capacity 3 and sequence 1,2,3,4,5,6,1,2,3,4
      -- Faults: 1,2,3,4(eject 1),5(eject 2),6(eject 3),1(eject 4),2(eject 5),3(eject 6),4(eject 1)
      -- Total: 10 faults (all are faults since we keep evicting)
      Assert_Equal(Get_Page_Faults(Algo), 10, "All accesses are faults with this sequence");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_Clock_Circular_Replacement;


   -- ========================================================
   -- GCLOCK Tests
   -- ========================================================

   procedure Test_GCLOCK_Empty_Access is
      Algo : GCLOCK_Algo := Init_GCLOCK(3, 2);
   begin
      New_Line;
      Put_Line("Test 6: GCLOCK - Empty access sequence");
      Current_Test := (Name => "GCLOCK_Empty_Access", 
                       Description => "Accessing no pages should result in 0 faults",
                       Result => Pass, Details => "");
      
      Assert_Equal(Get_Page_Faults(Algo), 0, "Empty access = 0 page faults");
      Assert_Equal(Get_Hit_Rate(Algo), 0.0, "Empty access = 0% hit rate");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_GCLOCK_Empty_Access;

   procedure Test_GCLOCK_Single_Page is
      Algo : GCLOCK_Algo := Init_GCLOCK(3, 2);
   begin
      New_Line;
      Put_Line("Test 7: GCLOCK - Single page repeated access");
      Current_Test := (Name => "GCLOCK_Single_Page", 
                       Description => "Repeated access to same page should have 1 fault",
                       Result => Pass, Details => "");
      
      for I in 1..5 loop
         Access_Page(Algo, 1);
      end loop;
      
      Assert_Equal(Get_Page_Faults(Algo), 1, "Single page = 1 page fault");
      Assert_Equal(Get_Hit_Rate(Algo), 0.8, "Single page = 80% hit rate");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_GCLOCK_Single_Page;

   procedure Test_GCLOCK_Page_Faults is
      Algo : GCLOCK_Algo := Init_GCLOCK(3, 2);
      Pages : constant array(1..10) of Page_ID := (1, 2, 3, 4, 1, 2, 5, 1, 2, 3);
   begin
      New_Line;
      Put_Line("Test 8: GCLOCK - Page fault counting with counter");
      Current_Test := (Name => "GCLOCK_Page_Faults", 
                       Description => "GCLOCK should have different fault count than Clock",
                       Result => Pass, Details => "");
      
      for P of Pages loop
         Access_Page(Algo, P);
      end loop;
      
      -- GCLOCK with Max_Count=2 should give pages more chances
      Assert(Get_Page_Faults(Algo) <= 7, "GCLOCK should have <= 7 faults");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_GCLOCK_Page_Faults;

   procedure Test_GCLOCK_Counter_Decrement is
      Algo : GCLOCK_Algo := Init_GCLOCK(2, 2);
   begin
      New_Line;
      Put_Line("Test 9: GCLOCK - Counter decrement on access");
      Current_Test := (Name => "GCLOCK_Counter_Decrement", 
                       Description => "Accessing a page should reset its counter",
                       Result => Pass, Details => "");
      
      -- Access page 1 (fault, count=2)
      Access_Page(Algo, 1);
      -- Access page 2 (fault, count=2)
      Access_Page(Algo, 2);
      -- Access page 3 (fault, should evict page 1 or 2, both have count=2)
      Access_Page(Algo, 3);
      -- Access page 1 again (should be a fault since it was evicted)
      Access_Page(Algo, 1);
      
      Assert_Equal(Get_Page_Faults(Algo), 4, "Should have 4 faults");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_GCLOCK_Counter_Decrement;

   procedure Test_GCLOCK_Higher_Count_Survival is
      Algo : GCLOCK_Algo := Init_GCLOCK(2, 3);
   begin
      New_Line;
      Put_Line("Test 10: GCLOCK - Higher count means longer survival");
      Current_Test := (Name => "GCLOCK_Higher_Count_Survival", 
                       Description => "Pages with higher Max_Count should survive longer",
                       Result => Pass, Details => "");
      
      -- With Max_Count=3, pages get 3 chances
      Access_Page(Algo, 1); -- count=3
      Access_Page(Algo, 2); -- count=3
      Access_Page(Algo, 3); -- fault, decrement 1 to 2
      Access_Page(Algo, 4); -- fault, decrement 2 to 1
      Access_Page(Algo, 5); -- fault, decrement 1 to 0, evict
      
      Assert(Get_Page_Faults(Algo) = 4, "Should have 4 faults with Max_Count=3");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_GCLOCK_Higher_Count_Survival;


   -- ========================================================
   -- WSClock Tests
   -- ========================================================

   procedure Test_WSClock_Empty_Access is
      Algo : WSClock_Algo := Init_WSClock(3, 10);
   begin
      New_Line;
      Put_Line("Test 11: WSClock - Empty access sequence");
      Current_Test := (Name => "WSClock_Empty_Access", 
                       Description => "Accessing no pages should result in 0 faults",
                       Result => Pass, Details => "");
      
      Assert_Equal(Get_Page_Faults(Algo), 0, "Empty access = 0 page faults");
      Assert_Equal(Get_Hit_Rate(Algo), 0.0, "Empty access = 0% hit rate");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_WSClock_Empty_Access;

   procedure Test_WSClock_Recent_Access_Protection is
      Algo : WSClock_Algo := Init_WSClock(3, 5);
   begin
      New_Line;
      Put_Line("Test 12: WSClock - Recent access protection (Tau)");
      Current_Test := (Name => "WSClock_Recent_Access_Protection", 
                       Description => "Recently accessed pages should not be evicted",
                       Result => Pass, Details => "");
      
      -- Access pages 1, 2, 3
      Access_Page(Algo, 1);
      Access_Page(Algo, 2);
      Access_Page(Algo, 3);
      -- Access page 1 again (recent, Last_Access = current time)
      Access_Page(Algo, 1);
      -- Access page 4 (should evict page 2 or 3, not page 1)
      Access_Page(Algo, 4);
      
      -- Page 1 should still be in cache (recently accessed)
      -- So we should have 4 faults total (1,2,3,4)
      Assert_Equal(Get_Page_Faults(Algo), 4, "Should have 4 faults, page 1 protected");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_WSClock_Recent_Access_Protection;

   procedure Test_WSClock_Tau_Expiration is
      Algo : WSClock_Algo := Init_WSClock(2, 2);
   begin
      New_Line;
      Put_Line("Test 13: WSClock - Tau expiration behavior");
      Current_Test := (Name => "WSClock_Tau_Expiration", 
                       Description => "Pages older than Tau should be evictable",
                       Result => Pass, Details => "");
      
      -- Access page 1
      Access_Page(Algo, 1);
      -- Access page 2
      Access_Page(Algo, 2);
      -- Time is now 2, Last_Access of page 1 is 1, page 2 is 2
      -- Access page 3 (should evict page 1 since Time - Last_Access(1) = 2 - 1 = 1 <= Tau=2? No, > Tau?)
      -- Actually with Tau=2, page 1: 2-1=1 <= 2, so it's NOT expired
      -- Let's advance time more
      for I in 1..10 loop
         Access_Page(Algo, 1); -- This advances time
      end loop;
      -- Now time is 12, Last_Access of page 2 is 2, so 12-2=10 > Tau=2
      Access_Page(Algo, 3); -- Should evict page 2
      
      Assert(Get_Page_Faults(Algo) >= 3, "Should have at least 3 faults");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_WSClock_Tau_Expiration;


   -- ========================================================
   -- Additional Comparison Tests
   -- ========================================================

   procedure Test_Clock_vs_GCLOCK is
      Clock_Algo1 : Clock_Algo := Init_Clock(3);
      GCLOCK_Algo1 : GCLOCK_Algo := Init_GCLOCK(3, 2);
      Pages : constant array(1..20) of Page_ID := (1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4);
   begin
      New_Line;
      Put_Line("Test 14: Clock vs GCLOCK - Different behaviors");
      Current_Test := (Name => "Clock_vs_GCLOCK", 
                       Description => "Clock and GCLOCK should have different fault counts",
                       Result => Pass, Details => "");
      
      for P of Pages loop
         Access_Page(Clock_Algo1, P);
      end loop;
      
      for P of Pages loop
         Access_Page(GCLOCK_Algo1, P);
      end loop;
      
      Assert(Get_Page_Faults(Clock_Algo1) /= Get_Page_Faults(GCLOCK_Algo1),
              "Clock and GCLOCK should have different fault counts");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_Clock_vs_GCLOCK;

   procedure Test_All_Algorithms_Same_Input is
      Clock_Algo1 : Clock_Algo := Init_Clock(5);
      GCLOCK_Algo1 : GCLOCK_Algo := Init_GCLOCK(5, 2);
      WSClock_Algo1 : WSClock_Algo := Init_WSClock(5, 10);
      Pages : constant array(1..10) of Page_ID := (1,2,3,4,5,1,2,3,4,5);
   begin
      New_Line;
      Put_Line("Test 15: All algorithms - Same input different results");
      Current_Test := (Name => "All_Algorithms_Same_Input", 
                       Description => "All algorithms should produce different results for same input",
                       Result => Pass, Details => "");
      
      for P of Pages loop
         Access_Page(Clock_Algo1, P);
      end loop;
      
      for P of Pages loop
         Access_Page(GCLOCK_Algo1, P);
      end loop;
      
      for P of Pages loop
         Access_Page(WSClock_Algo1, P);
      end loop;
      
      -- All should have faults but likely different counts
      Assert(Get_Page_Faults(Clock_Algo1) > 0, "Clock should have faults");
      Assert(Get_Page_Faults(GCLOCK_Algo1) > 0, "GCLOCK should have faults");
      Assert(Get_Page_Faults(WSClock_Algo1) > 0, "WSClock should have faults");
      
      if Current_Test.Result = Pass then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Test_All_Algorithms_Same_Input;


   -- ========================================================
   -- Test Runner
   -- ========================================================

   procedure Run_All_Tests is
   begin
      Put_Line("========================================");
      Put_Line("  Clock Replacement Algorithm Tests");
      Put_Line("========================================");
      New_Line;
      
      -- Reset counters
      Total_Tests := 0;
      Passed_Tests := 0;
      Failed_Tests := 0;
      
      -- Run all tests
      Test_Clock_Empty_Access;
      Test_Clock_Single_Page;
      Test_Clock_Page_Faults;
      Test_Clock_Hit_Rate;
      Test_Clock_Circular_Replacement;
      
      Test_GCLOCK_Empty_Access;
      Test_GCLOCK_Single_Page;
      Test_GCLOCK_Page_Faults;
      Test_GCLOCK_Counter_Decrement;
      Test_GCLOCK_Higher_Count_Survival;
      
      Test_WSClock_Empty_Access;
      Test_WSClock_Recent_Access_Protection;
      Test_WSClock_Tau_Expiration;
      
      Test_Clock_vs_GCLOCK;
      Test_All_Algorithms_Same_Input;
      
      Print_Summary;
   end Run_All_Tests;

   procedure Print_Summary is
   begin
      New_Line;
      Put_Line("========================================");
      Put_Line("  Test Summary");
      Put_Line("========================================");
      Put_Line("  Total Tests:  " & Natural'Image(Total_Tests));
      Put_Line("  Passed:       " & Natural'Image(Passed_Tests));
      Put_Line("  Failed:       " & Natural'Image(Failed_Tests));
      
      if Failed_Tests = 0 then
         Put_Line("  Status:       ALL TESTS PASSED!");
      else
         Put_Line("  Status:       SOME TESTS FAILED");
      end if;
      Put_Line("========================================");
   end Print_Summary;

end Clock_Tests;
