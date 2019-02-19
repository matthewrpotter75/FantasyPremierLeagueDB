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
    public class GetPlayerPointsUnitTest : SqlDatabaseTestClass
    {

        public GetPlayerPointsUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPointsStatsTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPlayerPointsUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPointsByGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPointsByPlayerPositionTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPointsByGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition;
            this.dbo_GetPlayerPointsStatsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPointsByGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPointsByPlayerPositionTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPointsStatsByPlayerPositionTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPlayerPointsStatsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPointsByGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPointsByPlayerPositionTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerPointsByGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetPlayerPointsStatsTest_TestAction
            // 
            resources.ApplyResources(dbo_GetPlayerPointsStatsTest_TestAction, "dbo_GetPlayerPointsStatsTest_TestAction");
            // 
            // dbo_GetPlayerPointsStatsTestData
            // 
            this.dbo_GetPlayerPointsStatsTestData.PosttestAction = null;
            this.dbo_GetPlayerPointsStatsTestData.PretestAction = null;
            this.dbo_GetPlayerPointsStatsTestData.TestAction = dbo_GetPlayerPointsStatsTest_TestAction;
            // 
            // dbo_GetPlayerPointsByGameweekTestData
            // 
            this.dbo_GetPlayerPointsByGameweekTestData.PosttestAction = null;
            this.dbo_GetPlayerPointsByGameweekTestData.PretestAction = null;
            this.dbo_GetPlayerPointsByGameweekTestData.TestAction = dbo_GetPlayerPointsByGameweekTest_TestAction;
            // 
            // dbo_GetPlayerPointsByGameweekTest_TestAction
            // 
            dbo_GetPlayerPointsByGameweekTest_TestAction.Conditions.Add(GetPlayerPointsByGameweekNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPointsByGameweekTest_TestAction, "dbo_GetPlayerPointsByGameweekTest_TestAction");
            // 
            // dbo_GetPlayerPointsByPlayerPositionTestData
            // 
            this.dbo_GetPlayerPointsByPlayerPositionTestData.PosttestAction = null;
            this.dbo_GetPlayerPointsByPlayerPositionTestData.PretestAction = null;
            this.dbo_GetPlayerPointsByPlayerPositionTestData.TestAction = dbo_GetPlayerPointsByPlayerPositionTest_TestAction;
            // 
            // dbo_GetPlayerPointsByPlayerPositionTest_TestAction
            // 
            dbo_GetPlayerPointsByPlayerPositionTest_TestAction.Conditions.Add(GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPointsByPlayerPositionTest_TestAction, "dbo_GetPlayerPointsByPlayerPositionTest_TestAction");
            // 
            // dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData
            // 
            this.dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData.PosttestAction = null;
            this.dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData.PretestAction = null;
            this.dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData.TestAction = dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction;
            // 
            // dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction
            // 
            dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction.Conditions.Add(GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction, "dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest_TestAction");
            // 
            // dbo_GetPlayerPointsStatsByPlayerPositionTestData
            // 
            this.dbo_GetPlayerPointsStatsByPlayerPositionTestData.PosttestAction = null;
            this.dbo_GetPlayerPointsStatsByPlayerPositionTestData.PretestAction = null;
            this.dbo_GetPlayerPointsStatsByPlayerPositionTestData.TestAction = dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction;
            // 
            // dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction
            // 
            dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction.Conditions.Add(GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction, "dbo_GetPlayerPointsStatsByPlayerPositionTest_TestAction");
            // 
            // GetPlayerPointsByGameweekNotEmptyResultSetCondition
            // 
            GetPlayerPointsByGameweekNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPointsByGameweekNotEmptyResultSetCondition.Name = "GetPlayerPointsByGameweekNotEmptyResultSetCondition";
            GetPlayerPointsByGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition
            // 
            GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition.Name = "GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition";
            GetPlayerPointsByPlayerPositionNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition
            // 
            GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition.Name = "GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition";
            GetPlayerPointsForPlayerPositionCostAfterStartGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition
            // 
            GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition.Name = "GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition";
            GetPlayerPointsStatsByPlayerPositionNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData
            // 
            this.dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData.PosttestAction = null;
            this.dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData.PretestAction = null;
            this.dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData.TestAction = dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction;
            // 
            // dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction
            // 
            dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction.Conditions.Add(GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction, "dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest_TestAction");
            // 
            // GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition
            // 
            GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition.Enabled = true;
            GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition.Name = "GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition";
            GetPlayerCostSelectedExpectedPointsFormPointsNotEmptyResultSetCondition.ResultSet = 1;
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
        public void dbo_GetPlayerPointsStatsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPointsStatsTestData;
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
        public void dbo_GetPlayerPointsByGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPointsByGameweekTestData;
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
        public void dbo_GetPlayerPointsByPlayerPositionTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPointsByPlayerPositionTestData;
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
        public void dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData;
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
        public void dbo_GetPlayerPointsStatsByPlayerPositionTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPointsStatsByPlayerPositionTestData;
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
        public void dbo_GetPlayerCostSelectedExpectedPointsFormPointsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData;
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


        private SqlDatabaseTestActions dbo_GetPlayerPointsStatsTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPointsByGameweekTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPointsByPlayerPositionTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPointsForPlayerPositionCostAfterStartGameweekTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPointsStatsByPlayerPositionTestData;
        private SqlDatabaseTestActions dbo_GetPlayerCostSelectedExpectedPointsFormPointsTestData;
    }
}
