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
    public class GetPlayerPricesUnitTest : SqlDatabaseTestClass
    {

        public GetPlayerPricesUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPricesChangesTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPlayerPricesUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPricesChangesByNameSearchTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerPricesChangesNotEmptyResultSetCondition;
            this.dbo_GetPlayerPricesChangesTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPricesChangesByNameSearchTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPlayerPricesChangesTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPricesChangesByNameSearchTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerPricesChangesNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            // 
            // dbo_GetPlayerPricesChangesTestData
            // 
            this.dbo_GetPlayerPricesChangesTestData.PosttestAction = null;
            this.dbo_GetPlayerPricesChangesTestData.PretestAction = null;
            this.dbo_GetPlayerPricesChangesTestData.TestAction = dbo_GetPlayerPricesChangesTest_TestAction;
            // 
            // dbo_GetPlayerPricesChangesTest_TestAction
            // 
            dbo_GetPlayerPricesChangesTest_TestAction.Conditions.Add(GetPlayerPricesChangesNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPricesChangesTest_TestAction, "dbo_GetPlayerPricesChangesTest_TestAction");
            // 
            // dbo_GetPlayerPricesChangesByNameSearchTestData
            // 
            this.dbo_GetPlayerPricesChangesByNameSearchTestData.PosttestAction = null;
            this.dbo_GetPlayerPricesChangesByNameSearchTestData.PretestAction = null;
            this.dbo_GetPlayerPricesChangesByNameSearchTestData.TestAction = dbo_GetPlayerPricesChangesByNameSearchTest_TestAction;
            // 
            // dbo_GetPlayerPricesChangesByNameSearchTest_TestAction
            // 
            dbo_GetPlayerPricesChangesByNameSearchTest_TestAction.Conditions.Add(GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPricesChangesByNameSearchTest_TestAction, "dbo_GetPlayerPricesChangesByNameSearchTest_TestAction");
            // 
            // dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData
            // 
            this.dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData.PosttestAction = null;
            this.dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData.PretestAction = null;
            this.dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData.TestAction = dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction;
            // 
            // dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction
            // 
            dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction.Conditions.Add(GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction, "dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest_TestAction");
            // 
            // GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition
            // 
            GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition.Name = "GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition";
            GetPlayerPricesChangesByNameSearchNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition
            // 
            GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition.Name = "GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition";
            GetPlayerPricesChangesFromFirstPriceInSeasonNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerPricesChangesNotEmptyResultSetCondition
            // 
            GetPlayerPricesChangesNotEmptyResultSetCondition.Enabled = true;
            GetPlayerPricesChangesNotEmptyResultSetCondition.Name = "GetPlayerPricesChangesNotEmptyResultSetCondition";
            GetPlayerPricesChangesNotEmptyResultSetCondition.ResultSet = 1;
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
        public void dbo_GetPlayerPricesChangesTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPricesChangesTestData;
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
        public void dbo_GetPlayerPricesChangesByNameSearchTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPricesChangesByNameSearchTestData;
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
        public void dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData;
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
        private SqlDatabaseTestActions dbo_GetPlayerPricesChangesTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPricesChangesByNameSearchTestData;
        private SqlDatabaseTestActions dbo_GetPlayerPricesChangesFromFirstPriceInSeasonTestData;
    }
}
