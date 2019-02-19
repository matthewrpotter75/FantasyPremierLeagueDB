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
    public class GetBestSquadPlayerUnitTest : SqlDatabaseTestClass
    {

        public GetBestSquadPlayerUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetBestSquadPlayerUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestTeamBasedOnPredictionsTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetBestSquadPlayerDetailsTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetBestSquadPlayerDetailsNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetBestSquadPlayerDetailsRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetBestTeamPlayerPointsForGameweekRowCountCondition;
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetBestTeamBasedOnPredictionsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetBestTeamPlayerPointsForGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetBestSquadPlayerDetailsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetBestTeamBasedOnPredictionsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetBestSquadPlayerDetailsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetBestSquadPlayerDetailsNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetBestSquadPlayerDetailsRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetBestTeamPlayerPointsForGameweekRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction
            // 
            dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction.Conditions.Add(GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition);
            dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction.Conditions.Add(GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition);
            resources.ApplyResources(dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction, "dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction");
            // 
            // GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition
            // 
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition.Enabled = true;
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition.Name = "GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition";
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition
            // 
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition.Enabled = true;
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition.Name = "GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition";
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition.ResultSet = 1;
            GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsRowCountCondition.RowCount = 15;
            // 
            // dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData
            // 
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData.PosttestAction = null;
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData.PretestAction = null;
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData.TestAction = dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest_TestAction;
            // 
            // dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData
            // 
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData.PosttestAction = null;
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData.PretestAction = null;
            this.dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData.TestAction = dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction;
            // 
            // dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction
            // 
            dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition);
            dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition);
            resources.ApplyResources(dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction, "dbo_GetBestSquadPlayerPointsForGameweekPeriodTest_TestAction");
            // 
            // dbo_GetBestTeamBasedOnPredictionsTestData
            // 
            this.dbo_GetBestTeamBasedOnPredictionsTestData.PosttestAction = null;
            this.dbo_GetBestTeamBasedOnPredictionsTestData.PretestAction = null;
            this.dbo_GetBestTeamBasedOnPredictionsTestData.TestAction = dbo_GetBestTeamBasedOnPredictionsTest_TestAction;
            // 
            // dbo_GetBestTeamBasedOnPredictionsTest_TestAction
            // 
            resources.ApplyResources(dbo_GetBestTeamBasedOnPredictionsTest_TestAction, "dbo_GetBestTeamBasedOnPredictionsTest_TestAction");
            // 
            // dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData
            // 
            this.dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData.PosttestAction = null;
            this.dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData.PretestAction = null;
            this.dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData.TestAction = dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction;
            // 
            // dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction
            // 
            dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction, "dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest_TestAction");
            // 
            // dbo_GetBestTeamPlayerPointsForGameweekTestData
            // 
            this.dbo_GetBestTeamPlayerPointsForGameweekTestData.PosttestAction = null;
            this.dbo_GetBestTeamPlayerPointsForGameweekTestData.PretestAction = null;
            this.dbo_GetBestTeamPlayerPointsForGameweekTestData.TestAction = dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction;
            // 
            // dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction
            // 
            dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction.Conditions.Add(GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition);
            dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction.Conditions.Add(GetBestTeamPlayerPointsForGameweekRowCountCondition);
            resources.ApplyResources(dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction, "dbo_GetBestTeamPlayerPointsForGameweekTest_TestAction");
            // 
            // dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData
            // 
            this.dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData.PosttestAction = null;
            this.dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData.PretestAction = null;
            this.dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData.TestAction = dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction;
            // 
            // dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction
            // 
            dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition);
            dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition);
            resources.ApplyResources(dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction, "dbo_GetBestTeamPlayerPointsForGameweekPeriodTest_TestAction");
            // 
            // dbo_GetBestSquadPlayerDetailsTestData
            // 
            this.dbo_GetBestSquadPlayerDetailsTestData.PosttestAction = null;
            this.dbo_GetBestSquadPlayerDetailsTestData.PretestAction = null;
            this.dbo_GetBestSquadPlayerDetailsTestData.TestAction = dbo_GetBestSquadPlayerDetailsTest_TestAction;
            // 
            // dbo_GetBestSquadPlayerDetailsTest_TestAction
            // 
            dbo_GetBestSquadPlayerDetailsTest_TestAction.Conditions.Add(GetBestSquadPlayerDetailsNotEmptyResultSetCondition);
            dbo_GetBestSquadPlayerDetailsTest_TestAction.Conditions.Add(GetBestSquadPlayerDetailsRowCountCondition);
            resources.ApplyResources(dbo_GetBestSquadPlayerDetailsTest_TestAction, "dbo_GetBestSquadPlayerDetailsTest_TestAction");
            // 
            // GetBestSquadPlayerDetailsNotEmptyResultSetCondition
            // 
            GetBestSquadPlayerDetailsNotEmptyResultSetCondition.Enabled = true;
            GetBestSquadPlayerDetailsNotEmptyResultSetCondition.Name = "GetBestSquadPlayerDetailsNotEmptyResultSetCondition";
            GetBestSquadPlayerDetailsNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetBestSquadPlayerDetailsRowCountCondition
            // 
            GetBestSquadPlayerDetailsRowCountCondition.Enabled = true;
            GetBestSquadPlayerDetailsRowCountCondition.Name = "GetBestSquadPlayerDetailsRowCountCondition";
            GetBestSquadPlayerDetailsRowCountCondition.ResultSet = 1;
            GetBestSquadPlayerDetailsRowCountCondition.RowCount = 15;
            // 
            // GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition
            // 
            GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Enabled = true;
            GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Name = "GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition";
            GetBestSquadPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition
            // 
            GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition.Enabled = true;
            GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition.Name = "GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition";
            GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition.ResultSet = 1;
            GetBestSquadPlayerPointsForGameweekPeriodRowCountCondition.RowCount = 15;
            // 
            // GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition
            // 
            GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Enabled = true;
            GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Name = "GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition";
            GetBestTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition
            // 
            GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Enabled = true;
            GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Name = "GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition";
            GetBestTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition
            // 
            GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition.Enabled = true;
            GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition.Name = "GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition";
            GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition.ResultSet = 1;
            GetBestTeamPlayerPointsForGameweekPeriodRowCountCondition.RowCount = 11;
            // 
            // GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition
            // 
            GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition.Enabled = true;
            GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition.Name = "GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition";
            GetBestTeamPlayerPointsForGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetBestTeamPlayerPointsForGameweekRowCountCondition
            // 
            GetBestTeamPlayerPointsForGameweekRowCountCondition.Enabled = true;
            GetBestTeamPlayerPointsForGameweekRowCountCondition.Name = "GetBestTeamPlayerPointsForGameweekRowCountCondition";
            GetBestTeamPlayerPointsForGameweekRowCountCondition.ResultSet = 1;
            GetBestTeamPlayerPointsForGameweekRowCountCondition.RowCount = 11;
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
        public void dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData;
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
        public void dbo_GetBestSquadPlayerPointsForGameweekPeriodTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData;
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
        public void dbo_GetBestTeamBasedOnPredictionsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestTeamBasedOnPredictionsTestData;
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
        public void dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData;
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
        public void dbo_GetBestTeamPlayerPointsForGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestTeamPlayerPointsForGameweekTestData;
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
        public void dbo_GetBestTeamPlayerPointsForGameweekPeriodTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData;
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
        public void dbo_GetBestSquadPlayerDetailsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetBestSquadPlayerDetailsTestData;
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


        private SqlDatabaseTestActions dbo_GetBestSquadPlayerPointsForGameweekPeriodAcrossSeasonsTestData;
        private SqlDatabaseTestActions dbo_GetBestSquadPlayerPointsForGameweekPeriodTestData;
        private SqlDatabaseTestActions dbo_GetBestTeamBasedOnPredictionsTestData;
        private SqlDatabaseTestActions dbo_GetBestTeamPlayerPointsForEachGameweekInRangeTestData;
        private SqlDatabaseTestActions dbo_GetBestTeamPlayerPointsForGameweekTestData;
        private SqlDatabaseTestActions dbo_GetBestTeamPlayerPointsForGameweekPeriodTestData;
        private SqlDatabaseTestActions dbo_GetBestSquadPlayerDetailsTestData;
    }
}
