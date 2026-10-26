/* =========================================================
   PORTFOLIO: SPECIALTY INSURANCE PREMIUM ANALYTICS
   Database: SQL Server
   Currency: GBP
   All data is synthetic.
   ========================================================= */

-- Drop child table first to respect foreign keys.
DROP TABLE IF EXISTS dbo.FactPremiumTransaction;
DROP TABLE IF EXISTS dbo.DimPolicy;
DROP TABLE IF EXISTS dbo.DimBroker;
DROP TABLE IF EXISTS dbo.DimDate;
GO

/* 1. Date dimension */

CREATE TABLE dbo.DimDate
(
    DateKey       INT          NOT NULL PRIMARY KEY,
    [Date]        DATE         NOT NULL UNIQUE,
    [Year]        SMALLINT     NOT NULL,
    QuarterNumber TINYINT      NOT NULL,
    MonthNumber   TINYINT      NOT NULL,
    MonthName     VARCHAR(10)  NOT NULL,
    YearMonth     CHAR(7)      NOT NULL
);
GO

/* 2. Broker dimension */

CREATE TABLE dbo.DimBroker
(
    BrokerKey     INT           NOT NULL PRIMARY KEY,
    BrokerCode    VARCHAR(20)   NOT NULL UNIQUE,
    BrokerName    VARCHAR(100)  NOT NULL,
    Country       VARCHAR(50)   NOT NULL
);
GO

/* 3. Policy dimension */

CREATE TABLE dbo.DimPolicy
(
    PolicyKey     INT           NOT NULL PRIMARY KEY,
    PolicyNumber  VARCHAR(30)   NOT NULL UNIQUE,
    ProductName   VARCHAR(60)   NOT NULL,
    PolicyStatus  VARCHAR(20)   NOT NULL,
    CurrencyCode  CHAR(3)       NOT NULL,

    CONSTRAINT CK_DimPolicy_Status
        CHECK (PolicyStatus IN ('Active', 'Expired', 'Cancelled')),

    CONSTRAINT CK_DimPolicy_Product
        CHECK (ProductName IN
        (
            'Cyber Liability',
            'Professional Indemnity',
            'Marine Cargo',
            'Environmental Liability'
        ))
);
GO

/* 4. Premium transaction fact table */

CREATE TABLE dbo.FactPremiumTransaction
(
    PremiumTransactionKey INT            NOT NULL PRIMARY KEY,
    TransactionReference  VARCHAR(30)    NOT NULL UNIQUE,
    DateKey               INT            NOT NULL,
    PolicyKey             INT            NOT NULL,
    BrokerKey             INT            NOT NULL,
    TransactionType       VARCHAR(20)    NOT NULL,
    PremiumAmount         DECIMAL(18, 2) NOT NULL,

    CONSTRAINT FK_Premium_Date
        FOREIGN KEY (DateKey)
        REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_Premium_Policy
        FOREIGN KEY (PolicyKey)
        REFERENCES dbo.DimPolicy(PolicyKey),

    CONSTRAINT FK_Premium_Broker
        FOREIGN KEY (BrokerKey)
        REFERENCES dbo.DimBroker(BrokerKey),

    CONSTRAINT CK_Premium_TransactionType
        CHECK (TransactionType IN
        (
            'New Business',
            'Renewal',
            'Endorsement',
            'Cancellation'
        ))
);
GO