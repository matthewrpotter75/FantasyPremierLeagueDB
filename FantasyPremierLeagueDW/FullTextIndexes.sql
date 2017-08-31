CREATE FULLTEXT INDEX ON [dbo].[DimPlayer]
    ([PlayerName] LANGUAGE 1033)
    KEY INDEX [PK_DimPlayer]
    ON [FT_FantasyPremierLeagueDW];

