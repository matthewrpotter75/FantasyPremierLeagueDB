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
    public class GetPlayerTotalPointsUnitTest : SqlDatabaseTestClass
    {

        public GetPlayerTotalPointsUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerTotalPointsForSeasonTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPlayerTotalPointsUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPlayerTotalPointsForSeasonRowCountCondition;
            this.dbo_GetPlayerTotalPointsForSeasonTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPlayerTotalPointsForSeasonTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPlayerTotalPointsForSeasonRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetPlayerTotalPointsForSeasonTestData
            // 
            this.dbo_GetPlayerTotalPointsForSeasonTestData.PosttestAction = null;
            this.dbo_GetPlayerTotalPointsForSeasonTestData.PretestAction = null;
            this.dbo_GetPlayerTotalPointsForSeasonTestData.TestAction = dbo_GetPlayerTotalPointsForSeasonTest_TestAction;
            // 
            // dbo_GetPlayerTotalPointsForSeasonTest_TestAction
            // 
            dbo_GetPlayerTotalPointsForSeasonTest_TestAction.Conditions.Add(GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition);
            dbo_GetPlayerTotalPointsForSeasonTest_TestAction.Conditions.Add(GetPlayerTotalPointsForSeasonRowCountCondition);
            resources.ApplyResources(dbo_GetPlayerTotalPointsForSeasonTest_TestAction, "dbo_GetPlayerTotalPointsForSeasonTest_TestAction");
            // 
            // dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData
            // 
            this.dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData.PosttestAction = null;
            this.dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData.PretestAction = null;
            this.dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData.TestAction = dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction;
            // 
            // dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction
            // 
            dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction.Conditions.Add(GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition);
            dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction.Conditions.Add(GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition);
            resources.ApplyResources(dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction, "dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest_TestAction");
            // 
            // GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition
            // 
            GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition.Enabled = true;
            GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition.Name = "GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition";
            GetPlayerTotalPointsForSeasonMultiplePlayersNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition
            // 
            GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition.Enabled = true;
            GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition.Name = "GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition";
            GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition.ResultSet = 1;
            GetPlayerTotalPointsForSeasonMultiplePlayersRowCountCondition.RowCount = 3;
            // 
            // GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition
            // 
            GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition.Enabled = true;
            GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition.Name = "GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition";
            GetPlayerTotalPointsForSeasonNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPlayerTotalPointsForSeasonRowCountCondition
            // 
            GetPlayerTotalPointsForSeasonRowCountCondition.Enabled = true;
            GetPlayerTotalPointsForSeasonRowCountCondition.Name = "GetPlayerTotalPointsForSeasonRowCountCondition";
            GetPlayerTotalPointsForSeasonRowCountCondition.ResultSet = 1;
            GetPlayerTotalPointsForSeasonRowCountCondition.RowCount = 1;
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
        public void dbo_GetPlayerTotalPointsForSeasonTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerTotalPointsForSeasonTestData;
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
        public void dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData;
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
        private SqlDatabaseTestActions dbo_GetPlayerTotalPointsForSeasonTestData;
        private SqlDatabaseTestActions dbo_GetPlayerTotalPointsForSeasonMultiplePlayersTestData;
    }
}
