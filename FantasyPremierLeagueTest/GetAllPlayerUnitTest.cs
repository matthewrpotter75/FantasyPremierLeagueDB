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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition;
            this.dbo_GetAllPlayerPointsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetAllPlayerPointsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllPlayerPointsNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllPlayerPPGForSeasonPrevious5Previous10AndAllGameweeksNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
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
            // dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData
            // 
            this.dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData.PosttestAction = null;
            this.dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData.PretestAction = null;
            this.dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData.TestAction = dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction;
            // 
            // dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction
            // 
            dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction.Conditions.Add(GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction, "dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest_TestAction");
            // 
            // dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData
            // 
            this.dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData.PosttestAction = null;
            this.dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData.PretestAction = null;
            this.dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData.TestAction = dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction;
            // 
            // dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction
            // 
            dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction.Conditions.Add(GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction, "dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest_TestAction");
            // 
            // GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition
            // 
            GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition.Enabled = true;
            GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition.Name = "GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition";
            GetAllPlayerPPGForSeasonHalfAndSeasonPartNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition
            // 
            GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition.Enabled = true;
            GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition.Name = "GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition";
            GetAllPlayerPPGForHomeAgainstAwayMatchesNotEmptyResultSetCondition.ResultSet = 1;
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
        [TestMethod()]
        public void dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData;
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
        public void dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData;
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
        private SqlDatabaseTestActions dbo_GetAllPlayerPPGForHomeAgainstAwayMatchesTestData;
        private SqlDatabaseTestActions dbo_GetAllPlayerPPGForSeasonHalfAndSeasonPartTestData;
    }
}
