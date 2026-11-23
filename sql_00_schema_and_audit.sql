-- GRAHAM STABILITY DB: BUILD ORDER
-- A: Reset database and build final schema
-- B: Create dimension and fact tables
-- C: Load rules, companies, and financial history
-- D: Create audit views and run verification


-- A: RESET DATABASE AND BUILD FINAL SCHEMA
drop database if exists 
	graham_stability_db;

create database 
	graham_stability_db
character set 
	utf8mb4
collate 
	utf8mb4_unicode_ci; -- Case-insensitive Unicode collation ensures consistent matching across Windows and Linux


use graham_stability_db;

-- B: CREATE DIMENSION AND FACT TABLES
--    B1: SECTOR-SPECIFIC DEFENSIVE THRESHOLDS (INDUSTRIALS VS. REGULATED UTILITIES)
create table
    dim_graham_rules
        (
        SECTOR_RULE_ID varchar(20) not null,
        GRAHAM_SECTOR_TYPE varchar(20) not null,
        MIN_DECADE_GROWTH decimal(10, 4) not null default 0.3300,
        MIN_CURRENT_RATIO decimal(10, 4) null,
        MAX_LTD_TO_WC decimal(10, 4) null,
        MAX_DEBT_TO_BOOK decimal(10, 4) null,
        MAX_BLENDED_MULTIPLIER decimal(10, 4) not null default 22.5000,
        MAX_PE_RATIO decimal(10, 4) not null default 15.0000,
        MAX_PE_12M decimal(6, 2) not null,
        MAX_PE_7YR decimal(6, 2) not null,
        MAX_PB_RATIO decimal(10, 4) not null default 1.5000,
        MAX_OWNERSHIP_CAP decimal(10, 6) not null default 0.005000,

        primary key (SECTOR_RULE_ID)
        );


-- B2: FISCAL YEAR CALENDAR DIMENSION FOR ROLLING WINDOW CALCULATIONS
create table 
    dim_date
        (
        FISCAL_YEAR int not null,
        DECADE_LABEL varchar(15) not null,
		
        primary key (FISCAL_YEAR),
		constraint chk_dim_fiscal_year 
			check (FISCAL_YEAR between 2000 and 2050)
        );


-- B3: MASTER EQUITY REGISTER WITH CROSS-EXCHANGE COMPOSITE IDS AND QUALITATIVE STATUS FLAGS
create table 
    dim_company 
        (
        TICKER_ID varchar(25) not null,
        TICKER_SYMBOL varchar(15) not null,
        COMPANY_NAME varchar(150) not null,
        EXCHANGE_CODE varchar(15) not null,
        CURRENCY_CODE varchar(5) not null,
        SECTOR_RULE_ID varchar(20) not null,
        INDUSTRY_SUBSECTOR varchar(100) null,
        FISCAL_YEAR_END_MONTH varchar(10) null,
        NEXT_REPORT_MONTH varchar(10) null,
        QUALITATIVE_STATUS varchar(50) not null default 'ACTIVE',
        REENTRY_ELIGIBLE_YEAR int null,
		
        primary key (TICKER_ID),
		foreign key (SECTOR_RULE_ID)
			references dim_graham_rules (SECTOR_RULE_ID)
			on delete restrict
        );


-- B4: NORMALIZED MULTI-YEAR EPS AND DIVIDEND HISTORY (SUPPORTS ROLLING 10YR & 20YR CHECKS)
create table 
    fact_annual_fundamentals 
        (
        FUNDAMENTAL_ID varchar(35) not null,
        TICKER_ID varchar(25) not null,
        FISCAL_YEAR int not null,
        EPS_VALUE decimal(14 , 6 ) null,
        DIVIDEND_PER_SHARE decimal(14 , 6 ) null,
		
        primary key (FUNDAMENTAL_ID),
		foreign key (TICKER_ID)
			references dim_company (TICKER_ID)
			on delete cascade,
		foreign key (FISCAL_YEAR)
			references dim_date (FISCAL_YEAR)
			on delete restrict
        );


-- B5: LATEST BALANCE SHEET SNAPSHOT AND FOOTNOTE ASSET/EQUITY DEDUCTIONS FOR TANGIBLE BOOK VALUE
create table 
    fact_balance_sheet 
        (
        SNAPSHOT_ID varchar(35) not null,
        TICKER_ID varchar(25) not null,
        FISCAL_YEAR int not null,
        SNAPSHOT_DATE date not null,
        MR_MARKET_PRICE decimal(14 , 4 ) null,
        ORDINARY_SHARES_OUTSTANDING bigint null,
        CURRENT_ASSETS decimal(18 , 2 ) null,
        CURRENT_LIABILITIES decimal(18 , 2 ) null,
        GOODWILL_SOFTWARE_BRAND decimal(18 , 2 ) not null default 0.00,
        INTANGIBLE_ASSETS decimal(18 , 2 ) not null default 0.00,
        EQUITY_METHOD_INVESTMENTS decimal(18 , 2 ) not null default 0.00,
        RIGHT_OF_USE_ASSETS decimal(18 , 2 ) not null default 0.00,
        REGULATORY_WILDFIRE_ASSETS decimal(18 , 2 ) not null default 0.00,
        DERIVATIVE_INSURANCE_ASSETS decimal(18 , 2 ) not null default 0.00,
        DEFERRED_TAX_ASSETS decimal(18 , 2 ) not null default 0.00,
        NON_UTILITY_PROPERTY_SOLO decimal(18 , 2 ) not null default 0.00,
        SECURITIZED_ASSETS decimal(18 , 2 ) not null default 0.00,
        RISK_MGMT_UNAMORTIZED_ASSETS decimal(18 , 2 ) not null default 0.00,
        OTHER_POSTRETIREMENT_ASSETS decimal(18 , 2 ) not null default 0.00,
        SHORT_TERM_DEBT decimal(18 , 2 ) not null default 0.00,
        LONG_TERM_DEBT decimal(18 , 2 ) not null default 0.00,
        SECURITIES_DEBENTURES_DEBT decimal(18 , 2 ) not null default 0.00,
        NOTES_BONDS_COMMERCIAL_PAPER decimal(18 , 2 ) not null default 0.00,
        LEASE_LIABILITIES_REDEEMABLE decimal(18 , 2 ) not null default 0.00,
        PENSION_ARO_OBLIGATIONS decimal(18 , 2 ) not null default 0.00,
        TREASURY_STOCK decimal(18 , 2 ) not null default 0.00,
        MEZZANINE_REDEEMABLE_PREFS decimal(18 , 2 ) not null default 0.00,
        PREFERRED_DIVIDEND_ARREARS decimal(18 , 2 ) not null default 0.00,
        PREFERRED_STOCK_LIQUIDATION decimal(18 , 2 ) not null default 0.00,
        PREFERRED_SHARE_PREMIUM decimal(18 , 2 ) not null default 0.00,
        PAYABLE_PROPOSED_DIVIDENDS decimal(18 , 2 ) not null default 0.00,
        REVALUATION_SURPLUS decimal(18 , 2 ) not null default 0.00,
        OTHER_LIABILITY_RESERVES decimal(18 , 2 ) not null default 0.00,
        HEDGE_RESERVES decimal(18 , 2 ) not null default 0.00,
        FAIR_VALUE_RESERVES decimal(18 , 2 ) not null default 0.00,
        NON_CONTROLLING_INTERESTS decimal(18 , 2 ) not null default 0.00,
        TOTAL_SHAREHOLDERS_EQUITY decimal(18 , 2 ) not null default 0.00,
		
        primary key (SNAPSHOT_ID),
		foreign key (TICKER_ID)
			references dim_company (TICKER_ID)
			on delete cascade,
		foreign key (FISCAL_YEAR)
			references dim_date (FISCAL_YEAR)
			on delete restrict
        );


-- C: LOAD RULES, COMPANIES, AND FINANCIAL HISTORY
--    C1: POPULATE FISCAL YEAR DIMENSION
insert into 
    dim_date
        (
        FISCAL_YEAR,
        DECADE_LABEL
        )
	
values
(2013, '2010s'), (2014, '2010s'), (2015, '2010s'), (2016, '2010s'),
(2017, '2010s'), (2018, '2010s'), (2019, '2010s'), (2020, '2020s'),
(2021, '2020s'), (2022, '2020s'), (2023, '2020s'), (2024, '2020s'),
(2025, '2020s'), (2026, '2020s');


-- C2: POPULATE SECTOR-SPECIFIC DEFENSIVE CRITERIA
insert into 
    dim_graham_rules
        (
        SECTOR_RULE_ID,
        GRAHAM_SECTOR_TYPE,
        MIN_DECADE_GROWTH,
        MIN_CURRENT_RATIO,
        MAX_LTD_TO_WC,
        MAX_DEBT_TO_BOOK,
        MAX_BLENDED_MULTIPLIER,
        MAX_PE_RATIO,
        MAX_PE_12M,
        MAX_PE_7YR,
        MAX_PB_RATIO,
        MAX_OWNERSHIP_CAP
        )
	
values
('RULE_INDUSTRIAL', 'INDUSTRIAL', 0.3300, 2.0000, 1.0000, null, 22.5000, 15.0000, 20.0000, 25.0000, 1.5000, 0.005000),
('RULE_UTILITY', 'UTILITY', 0.3300, null, null, 2.0000, 22.5000, 15.0000, 20.0000, 25.0000, 1.5000, 0.005000);


-- C3: POPULATE NYSE AND NSE BENCHMARK EQUITIES
insert into 
    dim_company
        (
        TICKER_ID,
        TICKER_SYMBOL,
        COMPANY_NAME,
        EXCHANGE_CODE,
        CURRENCY_CODE,
        SECTOR_RULE_ID,
        INDUSTRY_SUBSECTOR,
        FISCAL_YEAR_END_MONTH,
        NEXT_REPORT_MONTH,
        QUALITATIVE_STATUS,
        REENTRY_ELIGIBLE_YEAR
        )
	
values
('NYSE:AAON', 'AAON', 'AAON Inc.', 'NYSE', 'USD', 'RULE_INDUSTRIAL', 'HVAC & Industrial Equipment', 'DEC', 'MAR', 'ACTIVE', null),
('NYSE:ADM', 'ADM', 'Archer-Daniels-Midland', 'NYSE', 'USD', 'RULE_INDUSTRIAL', 'Agricultural Processing', 'DEC', 'MAR', 'ACTIVE', null),
('NYSE:ALG', 'ALG', 'Alamo Group Inc.', 'NYSE', 'USD', 'RULE_INDUSTRIAL', 'Industrial Machinery', 'DEC', 'MAR', 'ACTIVE', null),
('NYSE:ARTNA', 'ARTNA', 'Artesian Resources Corporation', 'NYSE', 'USD', 'RULE_UTILITY', 'Water Utility', 'DEC', 'MAR', 'ACTIVE', null),
('NYSE:ATO', 'ATO', 'Atmos Energy Corporation', 'NYSE', 'USD', 'RULE_UTILITY', 'Gas Utility', 'DEC', 'MAR', 'ACTIVE', null),
('NYSE:AWR', 'AWR', 'American States Water Company', 'NYSE', 'USD', 'RULE_UTILITY', 'Water Utility', 'DEC', 'MAR', 'ACTIVE', null),
('NSE:KEGN', 'KEGN', 'Kenya Electricity Generating Company PLC', 'NSE', 'KES', 'RULE_UTILITY', 'Electric Utility', 'JUN', 'DEC', 'ACTIVE', null),
('NSE:KPLC', 'KPLC', 'Kenya Power and Lighting Company PLC', 'NSE', 'KES', 'RULE_UTILITY', 'Electric Utility', 'JUN', 'DEC', 'REFORMED_DEFICITER', 2033),
('NSE:BAT', 'BAT', 'British American Tobacco Kenya PLC', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Consumer Manufacturing', 'DEC', 'JUL', 'ACTIVE', null),
('NSE:ARM', 'ARM', 'ARM Cement PLC', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Construction Materials', 'DEC', null, 'SUSPENDED', 2019);


-- C4: POPULATE MULTI-YEAR EPS SERIES FOR AAON AND ARTNA
insert into 
    fact_annual_fundamentals
        (
        FUNDAMENTAL_ID,
        TICKER_ID,
        FISCAL_YEAR,
        EPS_VALUE,
        DIVIDEND_PER_SHARE
        )
	
values
('NYSE:AAON_2013', 'NYSE:AAON', 2013, 0.453300, null),
('NYSE:AAON_2014', 'NYSE:AAON', 2014, 0.533300, null),
('NYSE:AAON_2015', 'NYSE:AAON', 2015, 0.560000, null),
('NYSE:AAON_2016', 'NYSE:AAON', 2016, 0.666600, null),
('NYSE:AAON_2017', 'NYSE:AAON', 2017, 0.673300, null),
('NYSE:AAON_2018', 'NYSE:AAON', 2018, 0.533300, null),
('NYSE:AAON_2019', 'NYSE:AAON', 2019, 0.680000, null),
('NYSE:AAON_2020', 'NYSE:AAON', 2020, 0.993333, null),
('NYSE:AAON_2021', 'NYSE:AAON', 2021, 0.730000, null),
('NYSE:AAON_2022', 'NYSE:AAON', 2022, 1.240000, null),
('NYSE:AAON_2023', 'NYSE:AAON', 2023, 2.130000, null),
('NYSE:AAON_2024', 'NYSE:AAON', 2024, 2.020000, null),
('NYSE:AAON_2025', 'NYSE:AAON', 2025, 1.290000, null),
('NYSE:ARTNA_2013', 'NYSE:ARTNA', 2013, 0.940000, null),
('NYSE:ARTNA_2014', 'NYSE:ARTNA', 2014, 1.070000, null),
('NYSE:ARTNA_2015', 'NYSE:ARTNA', 2015, 1.260000, null),
('NYSE:ARTNA_2016', 'NYSE:ARTNA', 2016, 1.410000, null),
('NYSE:ARTNA_2017', 'NYSE:ARTNA', 2017, 1.510000, null),
('NYSE:ARTNA_2018', 'NYSE:ARTNA', 2018, 1.540000, null),
('NYSE:ARTNA_2019', 'NYSE:ARTNA', 2019, 1.600000, null),
('NYSE:ARTNA_2020', 'NYSE:ARTNA', 2020, 1.790000, null),
('NYSE:ARTNA_2021', 'NYSE:ARTNA', 2021, 1.790000, null),
('NYSE:ARTNA_2022', 'NYSE:ARTNA', 2022, 1.900000, null),
('NYSE:ARTNA_2023', 'NYSE:ARTNA', 2023, 1.670000, null),
('NYSE:ARTNA_2024', 'NYSE:ARTNA', 2024, 1.980000, null),
('NYSE:ARTNA_2025', 'NYSE:ARTNA', 2025, 2.210000, null);


-- C5: POPULATE LATEST BALANCE SHEET SNAPSHOTS AND FOOTNOTE DEDUCTIONS
insert into 
    fact_balance_sheet
        (
        SNAPSHOT_ID,
        TICKER_ID,
        FISCAL_YEAR,
        SNAPSHOT_DATE,
        MR_MARKET_PRICE,
        ORDINARY_SHARES_OUTSTANDING,
        CURRENT_ASSETS,
        CURRENT_LIABILITIES,
        GOODWILL_SOFTWARE_BRAND,
        INTANGIBLE_ASSETS,
        EQUITY_METHOD_INVESTMENTS,
        RIGHT_OF_USE_ASSETS,
        REGULATORY_WILDFIRE_ASSETS,
        DERIVATIVE_INSURANCE_ASSETS,
        DEFERRED_TAX_ASSETS,
        NON_UTILITY_PROPERTY_SOLO,
        OTHER_POSTRETIREMENT_ASSETS,
        SHORT_TERM_DEBT,
        LONG_TERM_DEBT,
        LEASE_LIABILITIES_REDEEMABLE,
        TOTAL_SHAREHOLDERS_EQUITY
        )
	
values
('NYSE:AAON_2025', 'NYSE:AAON', 2025, '2026-03-01', 127.1900, 81691075, 869180000.00, 330855000.00, 0.00, 165799000.00, 0.00, 17988000.00, 0.00, 0.00, 0.00, 0.00, 2281000.00, 0.00, 398320000.00, 0.00, 894985000.00),
('NYSE:ARTNA_2025', 'NYSE:ARTNA', 2025, '2026-03-01', 31.6600, 10324438, null, null, 0.00, 10024000.00, 413000.00, 12287000.00, 0.00, 1939000.00, 0.00, 1764500.00, 0.00, 2558000.00, 183447000.00, 406000.00, 252798000.00);


-- D: CREATE AUDIT VIEWS AND RUN VERIFICATION
--    D1: ROLLING 3-YEAR EPS AVERAGES, 10-YEAR GROWTH, AND DEFICIT CHECK
create or replace view 
    vw_graham_eps_metrics 
as

with 
    latest_year_cte 
as
(
select
	TICKER_ID,
	max(FISCAL_YEAR) 
		as LATEST_YEAR
    
from 
	fact_annual_fundamentals
    
where 
	EPS_VALUE is not null
    
group by 
    1
)

select
    f.TICKER_ID,
    l.LATEST_YEAR,
    max(case when f.FISCAL_YEAR = l.LATEST_YEAR then f.EPS_VALUE end) 
        as LATEST_12M_EPS,
    avg(case when f.FISCAL_YEAR between l.LATEST_YEAR - 2 and l.LATEST_YEAR then f.EPS_VALUE end) 
        as END_3YR_AVG_EPS,
	avg(case when f.FISCAL_YEAR between l.LATEST_YEAR - 6 and l.LATEST_YEAR then f.EPS_VALUE end) 
        as AVG_7YR_EPS,
    avg(case when f.FISCAL_YEAR between l.LATEST_YEAR - 12 and l.LATEST_YEAR - 10 then f.EPS_VALUE end) 
        as START_3YR_AVG_EPS,
    (avg(case when f.FISCAL_YEAR between l.LATEST_YEAR - 2 and l.LATEST_YEAR then f.EPS_VALUE end) 
    - avg(case when f.FISCAL_YEAR between l.LATEST_YEAR - 12 and l.LATEST_YEAR - 10 then f.EPS_VALUE end)
    ) / 
    nullif(avg(case when f.FISCAL_YEAR between (l.LATEST_YEAR - 12) and (l.LATEST_YEAR - 10) then f.EPS_VALUE end), 0) 
        as DECADE_EPS_GROWTH,
    min(case when f.FISCAL_YEAR between l.LATEST_YEAR - 9 and l.LATEST_YEAR then f.EPS_VALUE end) 
        as MIN_10YR_EPS
    
from fact_annual_fundamentals f
join latest_year_cte l
    on f.TICKER_ID = l.TICKER_ID

group by 
    1, 2;


-- D2: CONSOLIDATED GRAHAM INTRINSIC VALUE, TANGIBLE BVPS, AND DEFENSIVE SCREENING MATRIX
create or replace view 
    vw_graham_valuation_matrix 
as

with 
balance_calculations 
as
(
select
    c.TICKER_ID,
    c.TICKER_SYMBOL,
    c.COMPANY_NAME,
    c.EXCHANGE_CODE,
    c.CURRENCY_CODE,
    r.GRAHAM_SECTOR_TYPE,
	c.QUALITATIVE_STATUS,
    c.REENTRY_ELIGIBLE_YEAR,
    b.FISCAL_YEAR 
        as SNAPSHOT_YEAR,
	b.SNAPSHOT_DATE 
        as BALANCE_SHEET_DATE,
    b.MR_MARKET_PRICE,
    b.ORDINARY_SHARES_OUTSTANDING,
    e.LATEST_12M_EPS,
    e.START_3YR_AVG_EPS,
    e.END_3YR_AVG_EPS,
    e.AVG_7YR_EPS,
    e.DECADE_EPS_GROWTH,
    e.MIN_10YR_EPS,
    (b.CURRENT_ASSETS - b.CURRENT_LIABILITIES) 
        as WORKING_CAPITAL,
    b.CURRENT_ASSETS / nullif(b.CURRENT_LIABILITIES, 0) 
        as CURRENT_RATIO,
    (
    b.SHORT_TERM_DEBT + b.LONG_TERM_DEBT + b.SECURITIES_DEBENTURES_DEBT +
    b.NOTES_BONDS_COMMERCIAL_PAPER + b.LEASE_LIABILITIES_REDEEMABLE + b.PENSION_ARO_OBLIGATIONS
    ) 
        as TOTAL_DEBT,
    (
    b.GOODWILL_SOFTWARE_BRAND + b.INTANGIBLE_ASSETS + b.EQUITY_METHOD_INVESTMENTS +
    b.RIGHT_OF_USE_ASSETS + b.REGULATORY_WILDFIRE_ASSETS + b.DERIVATIVE_INSURANCE_ASSETS +
    b.DEFERRED_TAX_ASSETS + b.NON_UTILITY_PROPERTY_SOLO + b.SECURITIZED_ASSETS +
    b.RISK_MGMT_UNAMORTIZED_ASSETS + b.OTHER_POSTRETIREMENT_ASSETS + b.TREASURY_STOCK +
    b.MEZZANINE_REDEEMABLE_PREFS + b.PREFERRED_DIVIDEND_ARREARS + b.PREFERRED_STOCK_LIQUIDATION +
    b.PREFERRED_SHARE_PREMIUM + b.PAYABLE_PROPOSED_DIVIDENDS + b.REVALUATION_SURPLUS +
    b.OTHER_LIABILITY_RESERVES + b.HEDGE_RESERVES + b.FAIR_VALUE_RESERVES + b.NON_CONTROLLING_INTERESTS
    ) 
        as TOTAL_DEDUCTIBLES,
    b.TOTAL_SHAREHOLDERS_EQUITY,
    r.MIN_DECADE_GROWTH,
    r.MIN_CURRENT_RATIO,
    r.MAX_LTD_TO_WC,
    r.MAX_DEBT_TO_BOOK,
    r.MAX_BLENDED_MULTIPLIER,
    r.MAX_PE_RATIO,
    r.MAX_PE_12M,
    r.MAX_PE_7YR

from dim_company c
join dim_graham_rules r
    on c.SECTOR_RULE_ID = r.SECTOR_RULE_ID
left join fact_balance_sheet b
    on c.TICKER_ID = b.TICKER_ID
left join vw_graham_eps_metrics e
    on c.TICKER_ID = e.TICKER_ID
),
	
valuation_metrics 
as
(
select
    *,
    (TOTAL_SHAREHOLDERS_EQUITY - TOTAL_DEDUCTIBLES) 
        as TANGIBLE_COMMON_EQUITY,
    (TOTAL_SHAREHOLDERS_EQUITY - TOTAL_DEDUCTIBLES) / nullif(ORDINARY_SHARES_OUTSTANDING, 0) 
        as TANGIBLE_BVPS,
    TOTAL_DEBT / nullif(WORKING_CAPITAL, 0) 
        as LTD_TO_WC_RATIO,
    TOTAL_DEBT / nullif((TOTAL_SHAREHOLDERS_EQUITY - TOTAL_DEDUCTIBLES), 0) 
        as DEBT_TO_BOOK_RATIO

from balance_calculations
)

select
    TICKER_ID,
    TICKER_SYMBOL,
    COMPANY_NAME,
    EXCHANGE_CODE,
    GRAHAM_SECTOR_TYPE,
    QUALITATIVE_STATUS,
    round(MR_MARKET_PRICE, 2) 
        as MR_MARKET_PRICE,
    BALANCE_SHEET_DATE,
    round(END_3YR_AVG_EPS, 4) 
        as END_3YR_AVG_EPS,
    round(DECADE_EPS_GROWTH, 4) 
        as DECADE_EPS_GROWTH,
    round(TANGIBLE_BVPS, 4) 
        as TANGIBLE_BVPS,
    round(CURRENT_RATIO, 4) 
        as CURRENT_RATIO,
    round(LTD_TO_WC_RATIO, 4) 
        as LTD_TO_WC_RATIO,
    round(DEBT_TO_BOOK_RATIO, 4) 
        as DEBT_TO_BOOK_RATIO,
    round
	(
	case
		when END_3YR_AVG_EPS > 0 
            and LATEST_12M_EPS > 0 
			and AVG_7YR_EPS > 0 
            and TANGIBLE_BVPS > 0 
			then least(
                sqrt(MAX_BLENDED_MULTIPLIER * END_3YR_AVG_EPS * TANGIBLE_BVPS),
                MAX_PE_RATIO * END_3YR_AVG_EPS,
				MAX_PE_12M * LATEST_12M_EPS,
				MAX_PE_7YR * AVG_7YR_EPS) 
        
		else null
        
		end, 4
	)
	    as GRAHAM_INTRINSIC_VALUE,
    case
        when QUALITATIVE_STATUS <> 'ACTIVE' 
            then concat('EXCLUDED: ', QUALITATIVE_STATUS)
        when SNAPSHOT_YEAR is null 
            then 'PENDING DATA'
        when MIN_10YR_EPS <= 0 or DECADE_EPS_GROWTH < MIN_DECADE_GROWTH 
            then 'FAIL: EARNINGS/GROWTH'
        when GRAHAM_SECTOR_TYPE = 'INDUSTRIAL' and (CURRENT_RATIO < MIN_CURRENT_RATIO or LTD_TO_WC_RATIO > MAX_LTD_TO_WC) 
            then 'FAIL: INDUSTRIAL SOLVENCY'
        when GRAHAM_SECTOR_TYPE = 'UTILITY' and DEBT_TO_BOOK_RATIO > MAX_DEBT_TO_BOOK 
            then 'FAIL: UTILITY DEBT/BOOK'
		when MR_MARKET_PRICE is null 
		    then 'PASS: AWAITING PRICE'
        when MR_MARKET_PRICE <= least(sqrt(MAX_BLENDED_MULTIPLIER * END_3YR_AVG_EPS * TANGIBLE_BVPS), MAX_PE_RATIO * END_3YR_AVG_EPS) 
            then 'BUY: AT OR BELOW I.V.'
        when MR_MARKET_PRICE <= 1.5 * least(sqrt(MAX_BLENDED_MULTIPLIER * END_3YR_AVG_EPS * TANGIBLE_BVPS), MAX_PE_RATIO * END_3YR_AVG_EPS) 
            then 'HOLD RANGE'
        
        else 'TOO DEAR / SELL'
        
        end 
	    as GRAHAM_VERDICT
        
from  valuation_metrics;


-- D3: AUDIT VERIFICATION OUTPUT
select 
    TICKER_ID,
    GRAHAM_SECTOR_TYPE,
    MR_MARKET_PRICE,
    BALANCE_SHEET_DATE,
    END_3YR_AVG_EPS,
    DECADE_EPS_GROWTH,
    TANGIBLE_BVPS,
    GRAHAM_INTRINSIC_VALUE,
    GRAHAM_VERDICT
    
from  vw_graham_valuation_matrix;
