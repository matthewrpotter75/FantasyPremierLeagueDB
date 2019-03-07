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
    public class GetUserTeamUnitTest : SqlDatabaseTestClass
    {

        public GetUserTeamUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetUserTeamUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamDifficultyTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamDifficultyNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetUserTeamDifficultyRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetUserTeamPlayerCurrentGameweekRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetUserTeamPlayerFixturesAndDifficultyRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetUserTeamPlayerPointsForGameweekRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetUserTeamPlayerSquadPointsForGameweekRowCountCondition;
            this.dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamDifficultyTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamPlayerCurrentGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamPlayerFixturesAndDifficultyTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamPlayerPointsForGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetUserTeamPlayerSquadPointsForGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetUserTeamDifficultyTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamDifficultyNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamDifficultyRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamPlayerCurrentGameweekRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamPlayerFixturesAndDifficultyRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamPlayerPointsForGameweekRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetUserTeamPlayerSquadPointsForGameweekRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction
            // 
            dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction, "dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction");
            // 
            // GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition
            // 
            GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Name = "GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition";
            GetUserTeamActualPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction
            // 
            dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition);
            dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results);
            dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints);
            resources.ApplyResources(dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction, "dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction");
            // 
            // GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition
            // 
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Name = "GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition";
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results
            // 
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results.Enabled = true;
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results.Name = "GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Resul" +
                "ts";
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Results.ResultSet = 2;
            // 
            // GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints
            // 
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints.Enabled = true;
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints.Name = "GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Total" +
                "Points";
            GetUserTeamBestPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_TotalPoints.ResultSet = 3;
            // 
            // dbo_GetUserTeamDifficultyTest_TestAction
            // 
            dbo_GetUserTeamDifficultyTest_TestAction.Conditions.Add(GetUserTeamDifficultyNotEmptyResultSetCondition);
            dbo_GetUserTeamDifficultyTest_TestAction.Conditions.Add(GetUserTeamDifficultyRowCountCondition);
            resources.ApplyResources(dbo_GetUserTeamDifficultyTest_TestAction, "dbo_GetUserTeamDifficultyTest_TestAction");
            // 
            // GetUserTeamDifficultyNotEmptyResultSetCondition
            // 
            GetUserTeamDifficultyNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamDifficultyNotEmptyResultSetCondition.Name = "GetUserTeamDifficultyNotEmptyResultSetCondition";
            GetUserTeamDifficultyNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetUserTeamDifficultyRowCountCondition
            // 
            GetUserTeamDifficultyRowCountCondition.Enabled = true;
            GetUserTeamDifficultyRowCountCondition.Name = "GetUserTeamDifficultyRowCountCondition";
            GetUserTeamDifficultyRowCountCondition.ResultSet = 1;
            GetUserTeamDifficultyRowCountCondition.RowCount = 15;
            // 
            // dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction
            // 
            dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction.Conditions.Add(GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition);
            dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction.Conditions.Add(GetUserTeamPlayerCurrentGameweekRowCountCondition);
            resources.ApplyResources(dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction, "dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction");
            // 
            // GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition
            // 
            GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition.Name = "GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition";
            GetUserTeamPlayerCurrentGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetUserTeamPlayerCurrentGameweekRowCountCondition
            // 
            GetUserTeamPlayerCurrentGameweekRowCountCondition.Enabled = true;
            GetUserTeamPlayerCurrentGameweekRowCountCondition.Name = "GetUserTeamPlayerCurrentGameweekRowCountCondition";
            GetUserTeamPlayerCurrentGameweekRowCountCondition.ResultSet = 1;
            GetUserTeamPlayerCurrentGameweekRowCountCondition.RowCount = 15;
            // 
            // dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction
            // 
            dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction.Conditions.Add(GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition);
            dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction.Conditions.Add(GetUserTeamPlayerFixturesAndDifficultyRowCountCondition);
            resources.ApplyResources(dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction, "dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction");
            // 
            // GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition
            // 
            GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition.Name = "GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition";
            GetUserTeamPlayerFixturesAndDifficultyNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetUserTeamPlayerFixturesAndDifficultyRowCountCondition
            // 
            GetUserTeamPlayerFixturesAndDifficultyRowCountCondition.Enabled = true;
            GetUserTeamPlayerFixturesAndDifficultyRowCountCondition.Name = "GetUserTeamPlayerFixturesAndDifficultyRowCountCondition";
            GetUserTeamPlayerFixturesAndDifficultyRowCountCondition.ResultSet = 1;
            GetUserTeamPlayerFixturesAndDifficultyRowCountCondition.RowCount = 15;
            // 
            // dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction
            // 
            dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction.Conditions.Add(GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition);
            dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction.Conditions.Add(GetUserTeamPlayerPointsForGameweekRowCountCondition);
            resources.ApplyResources(dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction, "dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction");
            // 
            // GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition
            // 
            GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition.Name = "GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition";
            GetUserTeamPlayerPointsForGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetUserTeamPlayerPointsForGameweekRowCountCondition
            // 
            GetUserTeamPlayerPointsForGameweekRowCountCondition.Enabled = true;
            GetUserTeamPlayerPointsForGameweekRowCountCondition.Name = "GetUserTeamPlayerPointsForGameweekRowCountCondition";
            GetUserTeamPlayerPointsForGameweekRowCountCondition.ResultSet = 1;
            GetUserTeamPlayerPointsForGameweekRowCountCondition.RowCount = 11;
            // 
            // dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction
            // 
            dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction.Conditions.Add(GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction, "dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction");
            // 
            // GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition
            // 
            GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition.Name = "GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition";
            GetUserTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction
            // 
            dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition);
            resources.ApplyResources(dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction, "dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction");
            // 
            // GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition
            // 
            GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Name = "GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition";
            GetUserTeamTotalPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction
            // 
            dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction.Conditions.Add(GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition);
            dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction.Conditions.Add(GetUserTeamPlayerSquadPointsForGameweekRowCountCondition);
            resources.ApplyResources(dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction, "dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction");
            // 
            // GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition
            // 
            GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition.Enabled = true;
            GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition.Name = "GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition";
            GetUserTeamPlayerSquadPointsForGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetUserTeamPlayerSquadPointsForGameweekRowCountCondition
            // 
            GetUserTeamPlayerSquadPointsForGameweekRowCountCondition.Enabled = true;
            GetUserTeamPlayerSquadPointsForGameweekRowCountCondition.Name = "GetUserTeamPlayerSquadPointsForGameweekRowCountCondition";
            GetUserTeamPlayerSquadPointsForGameweekRowCountCondition.ResultSet = 1;
            GetUserTeamPlayerSquadPointsForGameweekRowCountCondition.RowCount = 15;
            // 
            // dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData
            // 
            this.dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData.PosttestAction = null;
            this.dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData.PretestAction = null;
            this.dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData.TestAction = dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest_TestAction;
            // 
            // dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData
            // 
            this.dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData.PosttestAction = null;
            this.dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData.PretestAction = null;
            this.dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData.TestAction = dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest_TestAction;
            // 
            // dbo_GetUserTeamDifficultyTestData
            // 
            this.dbo_GetUserTeamDifficultyTestData.PosttestAction = null;
            this.dbo_GetUserTeamDifficultyTestData.PretestAction = null;
            this.dbo_GetUserTeamDifficultyTestData.TestAction = dbo_GetUserTeamDifficultyTest_TestAction;
            // 
            // dbo_GetUserTeamPlayerCurrentGameweekTestData
            // 
            this.dbo_GetUserTeamPlayerCurrentGameweekTestData.PosttestAction = null;
            this.dbo_GetUserTeamPlayerCurrentGameweekTestData.PretestAction = null;
            this.dbo_GetUserTeamPlayerCurrentGameweekTestData.TestAction = dbo_GetUserTeamPlayerCurrentGameweekTest_TestAction;
            // 
            // dbo_GetUserTeamPlayerFixturesAndDifficultyTestData
            // 
            this.dbo_GetUserTeamPlayerFixturesAndDifficultyTestData.PosttestAction = null;
            this.dbo_GetUserTeamPlayerFixturesAndDifficultyTestData.PretestAction = null;
            this.dbo_GetUserTeamPlayerFixturesAndDifficultyTestData.TestAction = dbo_GetUserTeamPlayerFixturesAndDifficultyTest_TestAction;
            // 
            // dbo_GetUserTeamPlayerPointsForGameweekTestData
            // 
            this.dbo_GetUserTeamPlayerPointsForGameweekTestData.PosttestAction = null;
            this.dbo_GetUserTeamPlayerPointsForGameweekTestData.PretestAction = null;
            this.dbo_GetUserTeamPlayerPointsForGameweekTestData.TestAction = dbo_GetUserTeamPlayerPointsForGameweekTest_TestAction;
            // 
            // dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData
            // 
            this.dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData.PosttestAction = null;
            this.dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData.PretestAction = null;
            this.dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData.TestAction = dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction;
            // 
            // dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData
            // 
            this.dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData.PosttestAction = null;
            this.dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData.PretestAction = null;
            this.dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData.TestAction = dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest_TestAction;
            // 
            // dbo_GetUserTeamPlayerSquadPointsForGameweekTestData
            // 
            this.dbo_GetUserTeamPlayerSquadPointsForGameweekTestData.PosttestAction = null;
            this.dbo_GetUserTeamPlayerSquadPointsForGameweekTestData.PretestAction = null;
            this.dbo_GetUserTeamPlayerSquadPointsForGameweekTestData.TestAction = dbo_GetUserTeamPlayerSquadPointsForGameweekTest_TestAction;
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
        public void dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData;
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
        public void dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData;
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
        public void dbo_GetUserTeamDifficultyTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamDifficultyTestData;
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
        public void dbo_GetUserTeamPlayerCurrentGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamPlayerCurrentGameweekTestData;
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
        public void dbo_GetUserTeamPlayerFixturesAndDifficultyTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamPlayerFixturesAndDifficultyTestData;
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
        public void dbo_GetUserTeamPlayerPointsForGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamPlayerPointsForGameweekTestData;
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
        public void dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData;
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
        public void dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData;
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
        public void dbo_GetUserTeamPlayerSquadPointsForGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetUserTeamPlayerSquadPointsForGameweekTestData;
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

        private SqlDatabaseTestActions dbo_GetUserTeamActualPlayerPointsForEachGameweekInRangeTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamBestPlayerPointsForEachGameweekInRangeTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamDifficultyTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamPlayerCurrentGameweekTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamPlayerFixturesAndDifficultyTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamPlayerPointsForGameweekTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamPlayerPointsPlayingAndBenchPlayersTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamTotalPlayerPointsForGameweekPeriodTestData;
        private SqlDatabaseTestActions dbo_GetUserTeamPlayerSquadPointsForGameweekTestData;
    }
}
