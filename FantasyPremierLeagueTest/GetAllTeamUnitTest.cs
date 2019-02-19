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
    public class GetAllTeamUnitTest : SqlDatabaseTestClass
    {

        public GetAllTeamUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetAllTeamFixturesAndDifficultyTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetAllTeamUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetAllTeamFixturesAndDifficultyRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetAllTeamsUpcomingAverageDifficultyRowCountCondition;
            this.dbo_GetAllTeamFixturesAndDifficultyTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetAllTeamsUpcomingAverageDifficultyTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetAllTeamFixturesAndDifficultyTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetAllTeamFixturesAndDifficultyRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetAllTeamsUpcomingAverageDifficultyRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetAllTeamFixturesAndDifficultyTest_TestAction
            // 
            dbo_GetAllTeamFixturesAndDifficultyTest_TestAction.Conditions.Add(GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition);
            dbo_GetAllTeamFixturesAndDifficultyTest_TestAction.Conditions.Add(GetAllTeamFixturesAndDifficultyRowCountCondition);
            resources.ApplyResources(dbo_GetAllTeamFixturesAndDifficultyTest_TestAction, "dbo_GetAllTeamFixturesAndDifficultyTest_TestAction");
            // 
            // GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition
            // 
            GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition.Enabled = true;
            GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition.Name = "GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition";
            GetAllTeamFixturesAndDifficultyNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetAllTeamFixturesAndDifficultyRowCountCondition
            // 
            GetAllTeamFixturesAndDifficultyRowCountCondition.Enabled = true;
            GetAllTeamFixturesAndDifficultyRowCountCondition.Name = "GetAllTeamFixturesAndDifficultyRowCountCondition";
            GetAllTeamFixturesAndDifficultyRowCountCondition.ResultSet = 1;
            GetAllTeamFixturesAndDifficultyRowCountCondition.RowCount = 20;
            // 
            // dbo_GetAllTeamFixturesAndDifficultyTestData
            // 
            this.dbo_GetAllTeamFixturesAndDifficultyTestData.PosttestAction = null;
            this.dbo_GetAllTeamFixturesAndDifficultyTestData.PretestAction = null;
            this.dbo_GetAllTeamFixturesAndDifficultyTestData.TestAction = dbo_GetAllTeamFixturesAndDifficultyTest_TestAction;
            // 
            // dbo_GetAllTeamsUpcomingAverageDifficultyTestData
            // 
            this.dbo_GetAllTeamsUpcomingAverageDifficultyTestData.PosttestAction = null;
            this.dbo_GetAllTeamsUpcomingAverageDifficultyTestData.PretestAction = null;
            this.dbo_GetAllTeamsUpcomingAverageDifficultyTestData.TestAction = dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction;
            // 
            // dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction
            // 
            dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction.Conditions.Add(GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition);
            dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction.Conditions.Add(GetAllTeamsUpcomingAverageDifficultyRowCountCondition);
            resources.ApplyResources(dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction, "dbo_GetAllTeamsUpcomingAverageDifficultyTest_TestAction");
            // 
            // GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition
            // 
            GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition.Enabled = true;
            GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition.Name = "GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition";
            GetAllTeamsUpcomingAverageDifficultyNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetAllTeamsUpcomingAverageDifficultyRowCountCondition
            // 
            GetAllTeamsUpcomingAverageDifficultyRowCountCondition.Enabled = true;
            GetAllTeamsUpcomingAverageDifficultyRowCountCondition.Name = "GetAllTeamsUpcomingAverageDifficultyRowCountCondition";
            GetAllTeamsUpcomingAverageDifficultyRowCountCondition.ResultSet = 1;
            GetAllTeamsUpcomingAverageDifficultyRowCountCondition.RowCount = 20;
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
        public void dbo_GetAllTeamFixturesAndDifficultyTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetAllTeamFixturesAndDifficultyTestData;
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
        public void dbo_GetAllTeamsUpcomingAverageDifficultyTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetAllTeamsUpcomingAverageDifficultyTestData;
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

        private SqlDatabaseTestActions dbo_GetAllTeamFixturesAndDifficultyTestData;
        private SqlDatabaseTestActions dbo_GetAllTeamsUpcomingAverageDifficultyTestData;
    }
}
