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
    public class GetTotalPointsUnitTest : SqlDatabaseTestClass
    {

        public GetTotalPointsUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetTotalPointsUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition;
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData
            // 
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData.PosttestAction = null;
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData.PretestAction = null;
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData.TestAction = dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction;
            // 
            // dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction
            // 
            dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction.Conditions.Add(GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition);
            dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction.Conditions.Add(GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition);
            resources.ApplyResources(dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction, "dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest_TestAction");
            // 
            // dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData
            // 
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData.PosttestAction = null;
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData.PretestAction = null;
            this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData.TestAction = dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction;
            // 
            // dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction
            // 
            dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction.Conditions.Add(GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition);
            dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction.Conditions.Add(GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition);
            resources.ApplyResources(dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction, "dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest_TestAction");
            // 
            // dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData
            // 
            this.dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData.PosttestAction = null;
            this.dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData.PretestAction = null;
            this.dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData.TestAction = dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction;
            // 
            // dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction
            // 
            dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction.Conditions.Add(GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition);
            dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction.Conditions.Add(GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition);
            resources.ApplyResources(dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction, "dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest_TestAction");
            // 
            // GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition
            // 
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition.Enabled = true;
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition.Name = "GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition";
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition
            // 
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition.Enabled = true;
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition.Name = "GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition";
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition.ResultSet = 1;
            GetTotalPointsByPlayerPositionAndGameweekRangePivotedRowCountCondition.RowCount = 20;
            // 
            // GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition
            // 
            GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition.Enabled = true;
            GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition.Name = "GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition";
            GetTotalPointsByPlayerPositionAndGameweekRangeNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition
            // 
            GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition.Enabled = true;
            GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition.Name = "GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition";
            GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition.ResultSet = 1;
            GetTotalPointsByPlayerPositionAndGameweekRangeRowCountCondition.RowCount = 4;
            // 
            // GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition
            // 
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition.Enabled = true;
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition.Name = "GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition";
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition
            // 
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition.Enabled = true;
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition.Name = "GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition";
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition.ResultSet = 1;
            GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeRowCountCondition.RowCount = 80;
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
        public void dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData;
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
        public void dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData;
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
        public void dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData;
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

        private SqlDatabaseTestActions dbo_GetTotalPointsByPlayerPositionAndGameweekRangeTestData;
        private SqlDatabaseTestActions dbo_GetTotalPointsByPlayerPositionAndGameweekRangePivotedTestData;
        private SqlDatabaseTestActions dbo_GetTotalPointsByTeamAndPlayerPositionAndGameweekRangeTestData;
    }
}
