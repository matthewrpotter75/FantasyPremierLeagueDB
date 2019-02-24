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
    public class GetPossibleTeamUnitTest : SqlDatabaseTestClass
    {

        public GetPossibleTeamUnitTest()
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamDifficultyTest_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GetPossibleTeamUnitTest));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamDifficultyNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamDifficultyRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamFixturesAndDifficultyRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamPlayerPointsTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamPlayerPointsRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamPlayerPointsByGameweekRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamPlayerPointsForGameweekRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition;
            this.dbo_GetPossibleTeamDifficultyTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamFixturesAndDifficultyTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamPlayerPointsTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamPlayerPointsByGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamPlayerPointsForGameweekTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            dbo_GetPossibleTeamDifficultyTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamDifficultyNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamDifficultyRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamFixturesAndDifficultyRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetPossibleTeamPlayerPointsTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamPlayerPointsNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamPlayerPointsRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamPlayerPointsByGameweekRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamPlayerPointsForGameweekRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.NotEmptyResultSetCondition();
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.RowCountCondition();
            // 
            // dbo_GetPossibleTeamDifficultyTest_TestAction
            // 
            dbo_GetPossibleTeamDifficultyTest_TestAction.Conditions.Add(GetPossibleTeamDifficultyNotEmptyResultSetCondition);
            dbo_GetPossibleTeamDifficultyTest_TestAction.Conditions.Add(GetPossibleTeamDifficultyRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamDifficultyTest_TestAction, "dbo_GetPossibleTeamDifficultyTest_TestAction");
            // 
            // GetPossibleTeamDifficultyNotEmptyResultSetCondition
            // 
            GetPossibleTeamDifficultyNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamDifficultyNotEmptyResultSetCondition.Name = "GetPossibleTeamDifficultyNotEmptyResultSetCondition";
            GetPossibleTeamDifficultyNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamDifficultyRowCountCondition
            // 
            GetPossibleTeamDifficultyRowCountCondition.Enabled = true;
            GetPossibleTeamDifficultyRowCountCondition.Name = "GetPossibleTeamDifficultyRowCountCondition";
            GetPossibleTeamDifficultyRowCountCondition.ResultSet = 1;
            GetPossibleTeamDifficultyRowCountCondition.RowCount = 15;
            // 
            // dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction
            // 
            dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction.Conditions.Add(GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition);
            dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction.Conditions.Add(GetPossibleTeamFixturesAndDifficultyRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction, "dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction");
            // 
            // GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition
            // 
            GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition.Name = "GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition";
            GetPossibleTeamFixturesAndDifficultyNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamFixturesAndDifficultyRowCountCondition
            // 
            GetPossibleTeamFixturesAndDifficultyRowCountCondition.Enabled = true;
            GetPossibleTeamFixturesAndDifficultyRowCountCondition.Name = "GetPossibleTeamFixturesAndDifficultyRowCountCondition";
            GetPossibleTeamFixturesAndDifficultyRowCountCondition.ResultSet = 1;
            GetPossibleTeamFixturesAndDifficultyRowCountCondition.RowCount = 15;
            // 
            // dbo_GetPossibleTeamPlayerPointsTest_TestAction
            // 
            dbo_GetPossibleTeamPlayerPointsTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsNotEmptyResultSetCondition);
            dbo_GetPossibleTeamPlayerPointsTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamPlayerPointsTest_TestAction, "dbo_GetPossibleTeamPlayerPointsTest_TestAction");
            // 
            // GetPossibleTeamPlayerPointsNotEmptyResultSetCondition
            // 
            GetPossibleTeamPlayerPointsNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamPlayerPointsNotEmptyResultSetCondition.Name = "GetPossibleTeamPlayerPointsNotEmptyResultSetCondition";
            GetPossibleTeamPlayerPointsNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamPlayerPointsRowCountCondition
            // 
            GetPossibleTeamPlayerPointsRowCountCondition.Enabled = true;
            GetPossibleTeamPlayerPointsRowCountCondition.Name = "GetPossibleTeamPlayerPointsRowCountCondition";
            GetPossibleTeamPlayerPointsRowCountCondition.ResultSet = 1;
            GetPossibleTeamPlayerPointsRowCountCondition.RowCount = 15;
            // 
            // dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction
            // 
            dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition);
            dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsByGameweekRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction, "dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction");
            // 
            // GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition
            // 
            GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition.Name = "GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition";
            GetPossibleTeamPlayerPointsByGameweekNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamPlayerPointsByGameweekRowCountCondition
            // 
            GetPossibleTeamPlayerPointsByGameweekRowCountCondition.Enabled = true;
            GetPossibleTeamPlayerPointsByGameweekRowCountCondition.Name = "GetPossibleTeamPlayerPointsByGameweekRowCountCondition";
            GetPossibleTeamPlayerPointsByGameweekRowCountCondition.ResultSet = 1;
            GetPossibleTeamPlayerPointsByGameweekRowCountCondition.RowCount = 15;
            // 
            // dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction
            // 
            dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition);
            dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot);
            resources.ApplyResources(dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction, "dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction");
            // 
            // GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition
            // 
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.Name = "GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition";
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot
            // 
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot.Enabled = true;
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot.Name = "GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot" +
                "";
            GetPossibleTeamPlayerPointsForEachGameweekInRangeNotEmptyResultSetCondition_Pivot.ResultSet = 1;
            // 
            // dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction
            // 
            dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition);
            dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsForGameweekRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction, "dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction");
            // 
            // GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition
            // 
            GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition.Name = "GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition";
            GetPossibleTeamPlayerPointsForGameweekRotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamPlayerPointsForGameweekRowCountCondition
            // 
            GetPossibleTeamPlayerPointsForGameweekRowCountCondition.Enabled = true;
            GetPossibleTeamPlayerPointsForGameweekRowCountCondition.Name = "GetPossibleTeamPlayerPointsForGameweekRowCountCondition";
            GetPossibleTeamPlayerPointsForGameweekRowCountCondition.ResultSet = 1;
            GetPossibleTeamPlayerPointsForGameweekRowCountCondition.RowCount = 11;
            // 
            // dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction
            // 
            dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition);
            dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction, "dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction");
            // 
            // GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition
            // 
            GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.Name = "GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition";
            GetPossibleTeamPlayerPointsForGameweekPeriodNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction
            // 
            dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition);
            dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction.Conditions.Add(GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition);
            resources.ApplyResources(dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction, "dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction");
            // 
            // GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition
            // 
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition.Enabled = true;
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition.Name = "GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition";
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersNotEmptyResultSetCondition.ResultSet = 1;
            // 
            // GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition
            // 
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition.Enabled = true;
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition.Name = "GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition";
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition.ResultSet = 1;
            GetPossibleTeamPlayerPointsPlayingAndBenchPlayersRowCountCondition.RowCount = 15;
            // 
            // dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction
            // 
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek);
            dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction.Conditions.Add(GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek);
            resources.ApplyResources(dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction, "dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction");
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad.Name = "GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad";
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Squad.ResultSet = 1;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad.Name = "GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad";
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad.ResultSet = 1;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Squad.RowCount = 15;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition.Name = "GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosit" +
                "ion";
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosition.ResultSet = 3;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition.Name = "GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition";
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition.ResultSet = 3;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPosition.RowCount = 4;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek.Name = "GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPosit" +
                "ionAndGameweek";
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_PlayerPositionAndGameweek.ResultSet = 5;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek.Name = "GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGam" +
                "eweek";
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek.ResultSet = 5;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_PlayerPositionAndGameweek.RowCount = 4;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek.Name = "GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek";
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_Gameweek.ResultSet = 7;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek.Name = "GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek";
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek.ResultSet = 7;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_Gameweek.RowCount = 4;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek.Name = "GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPoints" +
                "ByGamewwek";
            GetPossibleTeamTotalPointsForGameweekPeriodNotEmptyResultSetCondition_TotalPointsByGamewwek.ResultSet = 9;
            // 
            // GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek
            // 
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek.Enabled = true;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek.Name = "GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGamewee" +
                "k";
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek.ResultSet = 9;
            GetPossibleTeamTotalPointsForGameweekPeriodRowCountCondition_TotalPointsByGameweek.RowCount = 1;
            // 
            // dbo_GetPossibleTeamDifficultyTestData
            // 
            this.dbo_GetPossibleTeamDifficultyTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamDifficultyTestData.PretestAction = null;
            this.dbo_GetPossibleTeamDifficultyTestData.TestAction = dbo_GetPossibleTeamDifficultyTest_TestAction;
            // 
            // dbo_GetPossibleTeamFixturesAndDifficultyTestData
            // 
            this.dbo_GetPossibleTeamFixturesAndDifficultyTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamFixturesAndDifficultyTestData.PretestAction = null;
            this.dbo_GetPossibleTeamFixturesAndDifficultyTestData.TestAction = dbo_GetPossibleTeamFixturesAndDifficultyTest_TestAction;
            // 
            // dbo_GetPossibleTeamPlayerPointsTestData
            // 
            this.dbo_GetPossibleTeamPlayerPointsTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsTestData.PretestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsTestData.TestAction = dbo_GetPossibleTeamPlayerPointsTest_TestAction;
            // 
            // dbo_GetPossibleTeamPlayerPointsByGameweekTestData
            // 
            this.dbo_GetPossibleTeamPlayerPointsByGameweekTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsByGameweekTestData.PretestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsByGameweekTestData.TestAction = dbo_GetPossibleTeamPlayerPointsByGameweekTest_TestAction;
            // 
            // dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData
            // 
            this.dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData.PretestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData.TestAction = dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest_TestAction;
            // 
            // dbo_GetPossibleTeamPlayerPointsForGameweekTestData
            // 
            this.dbo_GetPossibleTeamPlayerPointsForGameweekTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsForGameweekTestData.PretestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsForGameweekTestData.TestAction = dbo_GetPossibleTeamPlayerPointsForGameweekTest_TestAction;
            // 
            // dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData
            // 
            this.dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData.PretestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData.TestAction = dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest_TestAction;
            // 
            // dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData
            // 
            this.dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData.PretestAction = null;
            this.dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData.TestAction = dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest_TestAction;
            // 
            // dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData
            // 
            this.dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData.PosttestAction = null;
            this.dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData.PretestAction = null;
            this.dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData.TestAction = dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest_TestAction;
            // 
            // GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition
            // 
            GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition.Enabled = true;
            GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition.Name = "GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition";
            GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition.ResultSet = 1;
            GetPossibleTeamPlayerPointsForGameweekPeriodRowCountCondition.RowCount = 15;
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
        public void dbo_GetPossibleTeamDifficultyTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamDifficultyTestData;
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
        public void dbo_GetPossibleTeamFixturesAndDifficultyTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamFixturesAndDifficultyTestData;
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
        public void dbo_GetPossibleTeamPlayerPointsTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamPlayerPointsTestData;
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
        public void dbo_GetPossibleTeamPlayerPointsByGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamPlayerPointsByGameweekTestData;
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
        public void dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData;
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
        public void dbo_GetPossibleTeamPlayerPointsForGameweekTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamPlayerPointsForGameweekTestData;
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
        public void dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData;
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
        public void dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData;
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
        public void dbo_GetPossibleTeamTotalPointsForGameweekPeriodTest()
        {
            SqlDatabaseTestActions testActions = this.dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData;
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
        private SqlDatabaseTestActions dbo_GetPossibleTeamDifficultyTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamFixturesAndDifficultyTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamPlayerPointsTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamPlayerPointsByGameweekTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamPlayerPointsForEachGameweekInRangeTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamPlayerPointsForGameweekTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamPlayerPointsForGameweekPeriodTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamPlayerPointsPlayingAndBenchPlayersTestData;
        private SqlDatabaseTestActions dbo_GetPossibleTeamTotalPointsForGameweekPeriodTestData;
    }
}
