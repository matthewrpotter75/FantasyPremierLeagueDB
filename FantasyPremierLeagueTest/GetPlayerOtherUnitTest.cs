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
    public class GetPlayerOtherUnitTest : SqlDatabaseTestClass
    {

        public GetPlayerOtherUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPlayerOtherUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerMinutesByGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerMinutesByGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons;
            this.dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerMinutesByGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerMinutesByGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerMinutesByGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData
            // 
            this.dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData.PosttestAction = null;
            this.dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData.PretestAction = null;
            this.dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData.TestAction = dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction;
            // 
            // dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction
            // 
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey);
            dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction.Conditions.Add(GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons);
            resources.ApplyResources(dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction, "dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest_TestAction");
            // 
            // dbo_GetPlayerMinutesByGameweekTestData
            // 
            this.dbo_GetPlayerMinutesByGameweekTestData.PosttestAction = null;
            this.dbo_GetPlayerMinutesByGameweekTestData.PretestAction = null;
            this.dbo_GetPlayerMinutesByGameweekTestData.TestAction = dbo_GetPlayerMinutesByGameweekTest_TestAction;
            // 
            // dbo_GetPlayerMinutesByGameweekTest_TestAction
            // 
            dbo_GetPlayerMinutesByGameweekTest_TestAction.Conditions.Add(GetPlayerMinutesByGameweekNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerMinutesByGameweekTest_TestAction, "dbo_GetPlayerMinutesByGameweekTest_TestAction");
            // 
            // GetPlayerMinutesByGameweekNotEmptyResultSetCondition
            // 
            GetPlayerMinutesByGameweekNotEmptyResultSetCondition.Enabled = true;
            GetPlayerMinutesByGameweekNotEmptyResultSetCondition.Name = "GetPlayerMinutesByGameweekNotEmptyResultSetCondition";
            GetPlayerMinutesByGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name.ResultSet = 1;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_Name.RowCount = 1;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllS" +
                "easons";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_AllSeasons.ResultSet = 3;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons.ResultSet = 3;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_AllSeasons.RowCount = 1;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Seas" +
                "onKey";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_SeasonKey.ResultSet = 5;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey.ResultSet = 5;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameRowCountCondition_SeasonKey.RowCount = 1;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDiffi" +
                "cultAndWasHome_SeasonKey";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetConditionDifficultAndWasHome_SeasonKey.ResultSet = 7;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Diff" +
                "icultyAndWasHome_AllSeasons";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_DifficultyAndWasHome_AllSeasons.ResultSet = 9;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Diff" +
                "iculty_SeasonKey";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_SeasonKey.ResultSet = 11;
            // 
            // GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons
            // 
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons.Enabled = true;
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons.Name = "GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Diff" +
                "iculty_AllSeasons";
            GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameNotEmptyResultSetCondition_Difficulty_AllSeasons.ResultSet = 13;
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
        public void dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData;
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
        public void dbo_GetPlayerMinutesByGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerMinutesByGameweekTestData;
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

        private SqlDatabaseTestActions dbo_GetPlayerStatsDifficultyAndIsHomeByPlayerKeyOrNameTestData;
        private SqlDatabaseTestActions dbo_GetPlayerMinutesByGameweekTestData;
    }
}
