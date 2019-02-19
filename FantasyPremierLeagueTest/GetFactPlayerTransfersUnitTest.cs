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
    public class GetFactPlayerTransfersUnitTest : SqlDatabaseTestClass
    {

        public GetFactPlayerTransfersUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetFactPlayerTransfersTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetFactPlayerTransfersUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetFactPlayerTransfersNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetFactPlayerTransfersForGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition;
            this.dbo_GetFactPlayerTransfersTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetFactPlayerTransfersForGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetFactPlayerTransfersTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetFactPlayerTransfersNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetFactPlayerTransfersForGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetFactPlayerTransfersTest_TestAction
            // 
            dbo_GetFactPlayerTransfersTest_TestAction.Conditions.Add(GetFactPlayerTransfersNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetFactPlayerTransfersTest_TestAction, "dbo_GetFactPlayerTransfersTest_TestAction");
            // 
            // GetFactPlayerTransfersNotEmptyResultSetCondition
            // 
            GetFactPlayerTransfersNotEmptyResultSetCondition.Enabled = true;
            GetFactPlayerTransfersNotEmptyResultSetCondition.Name = "GetFactPlayerTransfersNotEmptyResultSetCondition";
            GetFactPlayerTransfersNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetFactPlayerTransfersTestData
            // 
            this.dbo_GetFactPlayerTransfersTestData.PosttestAction = null;
            this.dbo_GetFactPlayerTransfersTestData.PretestAction = null;
            this.dbo_GetFactPlayerTransfersTestData.TestAction = dbo_GetFactPlayerTransfersTest_TestAction;
            // 
            // dbo_GetFactPlayerTransfersForGameweekTestData
            // 
            this.dbo_GetFactPlayerTransfersForGameweekTestData.PosttestAction = null;
            this.dbo_GetFactPlayerTransfersForGameweekTestData.PretestAction = null;
            this.dbo_GetFactPlayerTransfersForGameweekTestData.TestAction = dbo_GetFactPlayerTransfersForGameweekTest_TestAction;
            // 
            // dbo_GetFactPlayerTransfersForGameweekTest_TestAction
            // 
            dbo_GetFactPlayerTransfersForGameweekTest_TestAction.Conditions.Add(GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetFactPlayerTransfersForGameweekTest_TestAction, "dbo_GetFactPlayerTransfersForGameweekTest_TestAction");
            // 
            // GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition
            // 
            GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition.Enabled = true;
            GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition.Name = "GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition";
            GetFactPlayerTransfersForGameweekNotEmptyResultSetCondition.ResultSet = 1;
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
        public void dbo_GetFactPlayerTransfersTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetFactPlayerTransfersTestData;
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
        public void dbo_GetFactPlayerTransfersForGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetFactPlayerTransfersForGameweekTestData;
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

        private SqlDatabaseTestActions dbo_GetFactPlayerTransfersTestData;
        private SqlDatabaseTestActions dbo_GetFactPlayerTransfersForGameweekTestData;
    }
}
