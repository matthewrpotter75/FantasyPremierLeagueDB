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
    public class GetTeamUnitTest : SqlDatabaseTestClass
    {

        public GetTeamUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetTeamUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition;
            this.dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction
            // 
            dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition);
            dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team);
            dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results);
            dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition);
            resources.ApplyResources(dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction, "dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction");
            // 
            // dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction
            // 
            dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition);
            dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty);
            dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results);
            dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction.Conditions.Add(GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results);
            resources.ApplyResources(dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction, "dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestA" +
                    "ction");
            // 
            // dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction
            // 
            dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction.Conditions.Add(GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction, "dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction");
            // 
            // dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData
            // 
            this.dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData.PosttestAction = null;
            this.dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData.PretestAction = null;
            this.dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData.TestAction = dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction;
            // 
            // dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData
            // 
            this.dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData.PosttestAction = null;
            this.dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData.PretestAction = null;
            this.dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData.TestAction = dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest_TestAction;
            // 
            // dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData
            // 
            this.dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData.PosttestAction = null;
            this.dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData.PretestAction = null;
            this.dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData.TestAction = dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest_TestAction;
            // 
            // GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition
            // 
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition.Enabled = true;
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition.Name = "GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetConditi" +
                "on_PlayerPosition";
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition.ResultSet = 1;
            // 
            // GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team
            // 
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team.Enabled = true;
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team.Name = "GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetConditi" +
                "on_Team";
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Team.ResultSet = 2;
            // 
            // GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results
            // 
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.Enabled = true;
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.Name = "GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetConditi" +
                "on_Results";
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.ResultSet = 3;
            // 
            // GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition
            // 
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition.Enabled = true;
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition.Name = "GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition";
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition.ResultSet = 3;
            GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition.RowCount = 10;
            // 
            // GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition
            // 
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition.Enabled = true;
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition.Name = "GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResult" +
                "SetCondition_PlayerPosition";
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_PlayerPosition.ResultSet = 1;
            // 
            // GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty
            // 
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty.Enabled = true;
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty.Name = "GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResult" +
                "SetCondition_TeamDifficulty";
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_TeamDifficulty.ResultSet = 1;
            // 
            // GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results
            // 
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.Enabled = true;
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.Name = "GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResult" +
                "SetCondition_Results";
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeNotEmptyResultSetCondition_Results.ResultSet = 1;
            // 
            // GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results
            // 
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results.Enabled = true;
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results.Name = "GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondit" +
                "ion_Results";
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results.ResultSet = 3;
            GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeRowCountCondition_Results.RowCount = 10;
            // 
            // GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition
            // 
            GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition.Enabled = true;
            GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition.Name = "GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition";
            GetTeamPlayerPointsAndMinutesForGameweeksInSeasonNotEmptyResultSetCondition.ResultSet = 1;
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
        public void dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData;
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
        public void dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData;
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
        public void dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData;
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
        private SqlDatabaseTestActions dbo_GetTeamAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData;
        private SqlDatabaseTestActions dbo_GetTeamDifficultyAndPositionGameweekHistoryStatsByDifficultyWasHomeTestData;
        private SqlDatabaseTestActions dbo_GetTeamPlayerPointsAndMinutesForGameweeksInSeasonTestData;
    }
}
