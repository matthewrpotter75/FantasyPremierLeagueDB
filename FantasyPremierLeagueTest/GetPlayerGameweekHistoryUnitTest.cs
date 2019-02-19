using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace FantasyPremierLeagueTest
{
    [TestClass()]
    public class GetPlayerGameweekHistoryUnitTest : SqlDatabaseTestClass
    {

        public GetPlayerGameweekHistoryUnitTest()
        {
            InitializeComponent();
        }

        [TestInitialize()]
        public void TestInitialize()
        {
            base.InitializeTest();
        }
        [TestCleanup()]
        public void TestCleanup()
        {
            base.CleanupTest();
        }

        #region Designer support code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerGameweekHistoryTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPlayerGameweekHistoryUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerGameweekHistoryNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerGameweekHistoryComparisonTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition;
            this.dbo_GetPlayerGameweekHistoryTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerGameweekHistoryComparisonTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerGameweekHistoryForSeasonTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPlayerGameweekHistoryTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerGameweekHistoryNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPlayerGameweekHistoryComparisonTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetPlayerGameweekHistoryTest_TestAction
            // 
            dbo_GetPlayerGameweekHistoryTest_TestAction.Conditions.Add(GetPlayerGameweekHistoryNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerGameweekHistoryTest_TestAction, "dbo_GetPlayerGameweekHistoryTest_TestAction");
            // 
            // GetPlayerGameweekHistoryNotEmptyResultSetCondition
            // 
            GetPlayerGameweekHistoryNotEmptyResultSetCondition.Enabled = true;
            GetPlayerGameweekHistoryNotEmptyResultSetCondition.Name = "GetPlayerGameweekHistoryNotEmptyResultSetCondition";
            GetPlayerGameweekHistoryNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetPlayerGameweekHistoryComparisonTest_TestAction
            // 
            dbo_GetPlayerGameweekHistoryComparisonTest_TestAction.Conditions.Add(GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerGameweekHistoryComparisonTest_TestAction, "dbo_GetPlayerGameweekHistoryComparisonTest_TestAction");
            // 
            // GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition
            // 
            GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition.Enabled = true;
            GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition.Name = "GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition";
            GetPlayerGameweekHistoryComparisonNotEmptyResultSetCondition.ResultSet = 2;
            // 
            // dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction
            // 
            dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction.Conditions.Add(GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction, "dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction");
            // 
            // GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition
            // 
            GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition.Enabled = true;
            GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition.Name = "GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition";
            GetPlayerGameweekHistoryComparisonClub2ClubnotEmptyResultSetCondition.ResultSet = 2;
            // 
            // dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction
            // 
            dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name);
            dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results);
            resources.ApplyResources(dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction, "dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction");
            // 
            // GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name
            // 
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name.Enabled = true;
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name.Name = "GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name";
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Name.ResultSet = 1;
            // 
            // GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results
            // 
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.Enabled = true;
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.Name = "GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Result" +
                "s";
            GetPlayerGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.ResultSet = 2;
            // 
            // dbo_GetPlayerGameweekHistoryTestData
            // 
            this.dbo_GetPlayerGameweekHistoryTestData.PosttestAction = null;
            this.dbo_GetPlayerGameweekHistoryTestData.PretestAction = null;
            this.dbo_GetPlayerGameweekHistoryTestData.TestAction = dbo_GetPlayerGameweekHistoryTest_TestAction;
            // 
            // dbo_GetPlayerGameweekHistoryComparisonTestData
            // 
            this.dbo_GetPlayerGameweekHistoryComparisonTestData.PosttestAction = null;
            this.dbo_GetPlayerGameweekHistoryComparisonTestData.PretestAction = null;
            this.dbo_GetPlayerGameweekHistoryComparisonTestData.TestAction = dbo_GetPlayerGameweekHistoryComparisonTest_TestAction;
            // 
            // dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData
            // 
            this.dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData.PosttestAction = null;
            this.dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData.PretestAction = null;
            this.dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData.TestAction = dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest_TestAction;
            // 
            // dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData
            // 
            this.dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData.PosttestAction = null;
            this.dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData.PretestAction = null;
            this.dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData.TestAction = dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest_TestAction;
            // 
            // dbo_GetPlayerGameweekHistoryForSeasonTestData
            // 
            this.dbo_GetPlayerGameweekHistoryForSeasonTestData.PosttestAction = null;
            this.dbo_GetPlayerGameweekHistoryForSeasonTestData.PretestAction = null;
            this.dbo_GetPlayerGameweekHistoryForSeasonTestData.TestAction = dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction;
            // 
            // dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction
            // 
            dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction.Conditions.Add(GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction, "dbo_GetPlayerGameweekHistoryForSeasonTest_TestAction");
            // 
            // GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition
            // 
            GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition.Enabled = true;
            GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition.Name = "GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition";
            GetGameweekPlayerHistoryForSeasonNotEmptyResultSetCondition.ResultSet = 1;
        }

        #endregion


        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        #endregion

        [TestMethod()]
        public void dbo_GetPlayerGameweekHistoryTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerGameweekHistoryTestData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }
        [TestMethod()]
        public void dbo_GetPlayerGameweekHistoryComparisonTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerGameweekHistoryComparisonTestData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }

        [TestMethod()]
        public void dbo_GetPlayerGameweekHistoryComparisonClub2ClubTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }

        [TestMethod()]
        public void dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }
        [TestMethod()]
        public void dbo_GetPlayerGameweekHistoryForSeasonTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerGameweekHistoryForSeasonTestData;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }


        private SqlDatabaseTestActions dbo_GetPlayerGameweekHistoryTestData;
        private SqlDatabaseTestActions dbo_GetPlayerGameweekHistoryComparisonTestData;
        private SqlDatabaseTestActions dbo_GetPlayerGameweekHistoryComparisonClub2ClubTestData;
        private SqlDatabaseTestActions dbo_GetPlayerGameweekHistoryStatsByDifficultyWasHomeTestData;
        private SqlDatabaseTestActions dbo_GetPlayerGameweekHistoryForSeasonTestData;
    }
}
