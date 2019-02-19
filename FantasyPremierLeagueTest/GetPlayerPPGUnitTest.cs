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
    public class GetPlayerPPGUnitTest : SqlDatabaseTestClass
    {

        public GetPlayerPPGUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPlayerPPGUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPPGForGameweeksTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPPGForGameweeksNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerPPGForGameweeksRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition;
            this.dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPPGForGameweeksTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPlayerPPGForGameweeksTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerPPGForGameweeksNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPPGForGameweeksRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction
            // 
            dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction.Conditions.Add(GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction, "dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction");
            // 
            // GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition
            // 
            GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition.Name = "GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition";
            GetPlayerPPGByOpponentDificultyForGameweeksNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData
            // 
            this.dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData.PosttestAction = null;
            this.dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData.PretestAction = null;
            this.dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData.TestAction = dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest_TestAction;
            // 
            // dbo_GetPlayerPPGForGameweeksTestData
            // 
            this.dbo_GetPlayerPPGForGameweeksTestData.PosttestAction = null;
            this.dbo_GetPlayerPPGForGameweeksTestData.PretestAction = null;
            this.dbo_GetPlayerPPGForGameweeksTestData.TestAction = dbo_GetPlayerPPGForGameweeksTest_TestAction;
            // 
            // dbo_GetPlayerPPGForGameweeksTest_TestAction
            // 
            dbo_GetPlayerPPGForGameweeksTest_TestAction.Conditions.Add(GetPlayerPPGForGameweeksNotEmptyResultSetCondition);
            dbo_GetPlayerPPGForGameweeksTest_TestAction.Conditions.Add(GetPlayerPPGForGameweeksRowCountCondition);
            resources.ApplyResources(dbo_GetPlayerPPGForGameweeksTest_TestAction, "dbo_GetPlayerPPGForGameweeksTest_TestAction");
            // 
            // dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData
            // 
            this.dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData.PosttestAction = null;
            this.dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData.PretestAction = null;
            this.dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData.TestAction = dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction;
            // 
            // dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction
            // 
            dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction.Conditions.Add(GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition);
            dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction.Conditions.Add(GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition);
            resources.ApplyResources(dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction, "dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction");
            // 
            // GetPlayerPPGForGameweeksNotEmptyResultSetCondition
            // 
            GetPlayerPPGForGameweeksNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPPGForGameweeksNotEmptyResultSetCondition.Name = "GetPlayerPPGForGameweeksNotEmptyResultSetCondition";
            GetPlayerPPGForGameweeksNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPPGForGameweeksRowCountCondition
            // 
            GetPlayerPPGForGameweeksRowCountCondition.Enabled = true;
            GetPlayerPPGForGameweeksRowCountCondition.Name = "GetPlayerPPGForGameweeksRowCountCondition";
            GetPlayerPPGForGameweeksRowCountCondition.ResultSet = 1;
            GetPlayerPPGForGameweeksRowCountCondition.RowCount = 1;
            // 
            // GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition
            // 
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition.Name = "GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition" +
                "";
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition
            // 
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition.Enabled = true;
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition.Name = "GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition";
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition.ResultSet = 1;
            GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksRowCountCondition.RowCount = 1;
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
        public void dbo_GetPlayerPPGByOpponentDificultyForGameweeksTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData;
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
        public void dbo_GetPlayerPPGForGameweeksTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPPGForGameweeksTestData;
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
        public void dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData;
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

        private SqlDatabaseTestActions dbo_GetPlayerPPGByOpponentDificultyForGameweeksTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPPGForGameweeksTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData;
    }
}
