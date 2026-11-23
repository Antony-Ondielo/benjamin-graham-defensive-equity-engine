-- BATCH 1: NAIROBI SECURITIES EXCHANGE (NSE KENYA - KES)
-- 1A: Clear existing NSE test stubs for clean idempotent load
-- 1B: Load 16 NSE equities (4 audited active + 12 qualitative exclusions)
-- 1C: Load 13-year EPS history (2013-2025) for active NSE equities
-- 1D: Load latest balance sheet snapshots and footnote deductions
-- 1E: Verify NSE valuation matrix outputs


use graham_stability_db;


-- 1A: CLEAR EXISTING NSE TEST STUBS
delete from 
    dim_company 
where 
    EXCHANGE_CODE = 'NSE';


-- 1B: LOAD 16 NSE EQUITIES INTO MASTER REGISTER
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
    ('NSE:CARB', 'CARB', 'Carbacid Investments Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Industrial Gases & Manufacturing', 'JUL', 'NOV', 'ACTIVE', null),
    ('NSE:BAT', 'BAT', 'British American Tobacco Kenya Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Consumer Manufacturing', 'DEC', 'APR', 'ACTIVE', null),
    ('NSE:BOC', 'BOC', 'BOC Kenya Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Industrial Gases & Manufacturing', 'DEC', 'APR', 'ACTIVE', null),
    ('NSE:KEGN', 'KEGN', 'Kenya Electricity Generating Company Plc', 'NSE', 'KES', 'RULE_UTILITY', 'Electric Utilities', 'JUN', 'NOV', 'ACTIVE', null),
    ('NSE:ARM', 'ARM', 'ARM Cement Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Construction & Materials', 'DEC', null, 'SUSPENDED', null),
    ('NSE:MSC', 'MSC', 'Mumias Sugar Company Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Agricultural Manufacturing', 'DEC', null, 'SUSPENDED', null),
    ('NSE:CRWN', 'CRWN', 'Crown Paints Kenya Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Construction & Materials', 'DEC', null, 'COVID_DIV_MISS', null),
    ('NSE:EABL', 'EABL', 'East African Breweries Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Beverage Manufacturing', 'JUN', null, 'COVID_DIV_MISS', null),
    ('NSE:UNGA', 'UNGA', 'Unga Group Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Food Manufacturing', 'JUN', null, 'COVID_DIV_MISS', null),
    ('NSE:KPLC', 'KPLC', 'Kenya Power and Lighting Company Plc', 'NSE', 'KES', 'RULE_UTILITY', 'Electric Utilities', 'JUN', null, 'REFORMED_DEFICITER', 2033),
    ('NSE:UMME', 'UMME', 'Umeme Limited', 'NSE', 'KES', 'RULE_UTILITY', 'Electric Utilities', 'DEC', null, 'REFORMED_DEFICITER', 2035),
    ('NSE:BAMB', 'BAMB', 'Bamburi Cement Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Construction & Materials', 'DEC', null, 'REFORMED_DEFICITER', 2035),
    ('NSE:CABL', 'CABL', 'East African Cables Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Construction & Materials', 'DEC', null, 'REFORMED_DEFICITER', 2035),
    ('NSE:PORT', 'PORT', 'East African Portland Cement Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Construction & Materials', 'JUN', null, 'REFORMED_DEFICITER', 2035),
    ('NSE:FTGH', 'FTGH', 'Flame Tree Group Holdings Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Manufacturing', 'DEC', null, 'REFORMED_DEFICITER', 2035),
    ('NSE:SKL', 'SKL', 'Shri Krishana Overseas Plc', 'NSE', 'KES', 'RULE_INDUSTRIAL', 'Packaging & Manufacturing', 'DEC', null, 'REFORMED_DEFICITER', 2035);


-- 1C: LOAD 13-YEAR EPS HISTORY (2013-2025) FOR ACTIVE NSE EQUITIES
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
    ('NSE:CARB_2025', 'NSE:CARB', 2025, 3.940000, null),
    ('NSE:CARB_2024', 'NSE:CARB', 2024, 3.310000, null),
    ('NSE:CARB_2023', 'NSE:CARB', 2023, 3.200000, null),
    ('NSE:CARB_2022', 'NSE:CARB', 2022, 2.776765, null),
    ('NSE:CARB_2021', 'NSE:CARB', 2021, 1.628785, null),
    ('NSE:CARB_2020', 'NSE:CARB', 2020, 1.273892, null),
    ('NSE:CARB_2019', 'NSE:CARB', 2019, 1.038207, null),
    ('NSE:CARB_2018', 'NSE:CARB', 2018, 1.171370, null),
    ('NSE:CARB_2017', 'NSE:CARB', 2017, 1.382371, null),
    ('NSE:CARB_2016', 'NSE:CARB', 2016, 1.473671, null),
    ('NSE:CARB_2015', 'NSE:CARB', 2015, 1.545458, null),
    ('NSE:CARB_2014', 'NSE:CARB', 2014, 1.925200, null),
    ('NSE:CARB_2013', 'NSE:CARB', 2013, 1.865950, null),
    ('NSE:BAT_2025', 'NSE:BAT', 2025, 52.456170, null),
    ('NSE:BAT_2024', 'NSE:BAT', 2024, 44.833700, null),
    ('NSE:BAT_2023', 'NSE:BAT', 2023, 55.680170, null),
    ('NSE:BAT_2022', 'NSE:BAT', 2022, 68.919920, null),
    ('NSE:BAT_2021', 'NSE:BAT', 2021, 64.833810, null),
    ('NSE:BAT_2020', 'NSE:BAT', 2020, 55.180000, null),
    ('NSE:BAT_2019', 'NSE:BAT', 2019, 38.856490, null),
    ('NSE:BAT_2018', 'NSE:BAT', 2018, 40.845230, null),
    ('NSE:BAT_2017', 'NSE:BAT', 2017, 33.360060, null),
    ('NSE:BAT_2016', 'NSE:BAT', 2016, 42.343340, null),
    ('NSE:BAT_2015', 'NSE:BAT', 2015, 49.762560, null),
    ('NSE:BAT_2014', 'NSE:BAT', 2014, 42.553140, null),
    ('NSE:BAT_2013', 'NSE:BAT', 2013, 37.236910, null),
    ('NSE:BOC_2025', 'NSE:BOC', 2025, 16.080000, null),
    ('NSE:BOC_2024', 'NSE:BOC', 2024, 10.836326, null),
    ('NSE:BOC_2023', 'NSE:BOC', 2023, 10.140570, null),
    ('NSE:BOC_2022', 'NSE:BOC', 2022, 7.577190, null),
    ('NSE:BOC_2021', 'NSE:BOC', 2021, 5.547469, null),
    ('NSE:BOC_2020', 'NSE:BOC', 2020, 5.210000, null),
    ('NSE:BOC_2019', 'NSE:BOC', 2019, 2.862131, null),
    ('NSE:BOC_2018', 'NSE:BOC', 2018, 3.357542, null),
    ('NSE:BOC_2017', 'NSE:BOC', 2017, 2.016205, null),
    ('NSE:BOC_2016', 'NSE:BOC', 2016, 6.467738, null),
    ('NSE:BOC_2015', 'NSE:BOC', 2015, 7.608320, null),
    ('NSE:BOC_2014', 'NSE:BOC', 2014, 11.756800, null),
    ('NSE:BOC_2013', 'NSE:BOC', 2013, 10.380000, null),
    ('NSE:KEGN_2025', 'NSE:KEGN', 2025, 1.589361, null),
    ('NSE:KEGN_2024', 'NSE:KEGN', 2024, 1.030706, null),
    ('NSE:KEGN_2023', 'NSE:KEGN', 2023, 0.760704, null),
    ('NSE:KEGN_2022', 'NSE:KEGN', 2022, 0.512812, null),
    ('NSE:KEGN_2021', 'NSE:KEGN', 2021, 0.280000, null),
    ('NSE:KEGN_2020', 'NSE:KEGN', 2020, 2.786721, null),
    ('NSE:KEGN_2019', 'NSE:KEGN', 2019, 1.195588, null),
    ('NSE:KEGN_2018', 'NSE:KEGN', 2018, 1.196544, null),
    ('NSE:KEGN_2017', 'NSE:KEGN', 2017, 1.373432, null),
    ('NSE:KEGN_2016', 'NSE:KEGN', 2016, 1.080000, null),
    ('NSE:KEGN_2015', 'NSE:KEGN', 2015, 1.746499, null),
    ('NSE:KEGN_2014', 'NSE:KEGN', 2014, 0.430000, null),
    ('NSE:KEGN_2013', 'NSE:KEGN', 2013, 0.793333, null);


-- 1D: LOAD LATEST BALANCE SHEET SNAPSHOTS AND FOOTNOTE DEDUCTIONS
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
        OTHER_POSTRETIREMENT_ASSETS,
        LONG_TERM_DEBT,
        LEASE_LIABILITIES_REDEEMABLE,
        PAYABLE_PROPOSED_DIVIDENDS,
        REVALUATION_SURPLUS,
        OTHER_LIABILITY_RESERVES,
        HEDGE_RESERVES,
        TOTAL_SHAREHOLDERS_EQUITY
        )
    
values
    ('NSE:CARB_2025', 'NSE:CARB', 2025, '2025-07-31', 36.2000, 254852000, 1691646000.00, 604524000.00, 627110000.00, 3716000.00, 0.00, 0.00, 51516000.00, 500554000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5096829000.00),
    ('NSE:BAT_2025', 'NSE:BAT', 2025, '2025-12-31', 562.0000, 100000000, 13898130000.00, 6197535000.00, 0.00, 0.00, 229394000.00, 0.00, 0.00, 52405000.00, 0.00, 0.00, 6000000000.00, 2620380000.00, 6684000.00, 15485431000.00),
    ('NSE:BOC_2025', 'NSE:BOC', 2025, '2025-12-31', 170.0000, 19525446, 1717402000.00, 381189000.00, 0.00, 2012000.00, 51492000.00, 9138000.00, 0.00, 0.00, 7494000.00, 202088366.00, 0.00, 0.00, 0.00, 2195017000.00),
    ('NSE:KEGN_2025', 'NSE:KEGN', 2025, '2025-06-30', 9.8400, 6594522339, null, null, 0.00, 2226724000.00, 0.00, 6948159000.00, 0.00, 109271273000.00, 768324000.00, 5935070105.00, 110155763000.00, 0.00, 0.00, 282848000000.00);


-- 1E: VERIFY NSE VALUATION MATRIX OUTPUTS
select 
    TICKER_ID,
    GRAHAM_SECTOR_TYPE,
    MR_MARKET_PRICE,
    END_3YR_AVG_EPS,
    DECADE_EPS_GROWTH,
    TANGIBLE_BVPS,
    GRAHAM_INTRINSIC_VALUE,
    GRAHAM_VERDICT
    
from 
    vw_graham_valuation_matrix
    
where 
    TICKER_ID like 'NSE:%'
order by 
    1;
