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
    public class GetAllPlayerUnitTest : SqlDatabaseTestClass
    {

        public GetAllPlayerUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetAllPlayerPointsTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetAllPlayerUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetAllPlayerPointsNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition;
            this.dbo_GetAllPlayerPointsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetAllPlayerPointsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllPlayerPointsNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetAllPlayerPointsTest_TestAction
            // 
            dbo_GetAllPlayerPointsTest_TestAction.Conditions.Add(GetAllPlayerPointsNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetAllPlayerPointsTest_TestAction, "dbo_GetAllPlayerPointsTest_TestAction");
            // 
            // GetAllPlayerPointsNotEmptyResultSetCondition
            // 
            GetAllPlayerPointsNotEmptyResultSetCondition.Enabled = true;
            GetAllPlayerPointsNotEmptyResultSetCondition.Name = "GetAllPlayerPointsNotEmptyResultSetCondition";
            GetAllPlayerPointsNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetAllPlayerPointsTestData
            // 
            this.dbo_GetAllPlayerPointsTestData.PosttestAction = null;
            this.dbo_GetAllPlayerPointsTestData.PretestAction = null;
            this.dbo_GetAllPlayerPointsTestData.TestAction = dbo_GetAllPlayerPointsTest_TestAction;
            // 
            // dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData
            // 
            this.dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData.PosttestAction = null;
            this.dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData.PretestAction = null;
            this.dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData.TestAction = dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction;
            // 
            // dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction
            // 
            dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction.Conditions.Add(GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction, "dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction");
            // 
            // GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition
            // 
            GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition.Enabled = true;
            GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition.Name = "GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondit" +
                "ion";
            GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition.ResultSet = 1;
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
        public void dbo_GetAllPlayerPointsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetAllPlayerPointsTestData;
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
        public void dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData;
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

        private SqlDatabaseTestActions dbo_GetAllPlayerPointsTestData;
        private SqlDatabaseTestActions dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData;
    }
}
