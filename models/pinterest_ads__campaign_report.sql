{{ config(enabled=var('ad_reporting__pinterest_ads_enabled', True),
    unique_key = ['source_relation','campaign_id','advertiser_id','date_day'],
    partition_by={
      "field": "date_day", 
      "data_type": "TIMESTAMP",
      "granularity": "day"
    }
    ) }}

with report as (
    select *
    from {{ var('campaign_report') }}
),

campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = True
),

advertisers as (
    select *
    from {{ var('advertiser_history') }}
    where is_most_recent_record = True
),

fields as (

    select
        report.source_relation,
        report.date_day,
        advertisers.advertiser_name,
        advertisers.advertiser_id,
        campaigns.campaign_name,
        report.campaign_id,
        campaigns.campaign_status,
        sum(report.spend) as spend,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.total_conversions) as total_conversions,
        sum(report.total_conversions_quantity) as total_conversions_quantity,
        sum(report.total_conversions_value) as total_conversions_value

        {{ pinterest_ads_persist_pass_through_columns(pass_through_variable='pinterest__campaign_report_passthrough_metrics', identifier='report', transform='sum', coalesce_with=0, exclude_fields=['total_conversions','total_conversions_quantity','total_conversions_value']) }}

    from report
    left join campaigns
        on report.campaign_id = campaigns.campaign_id
        and report.source_relation = campaigns.source_relation
    left join advertisers
        on campaigns.advertiser_id = advertisers.advertiser_id
        and campaigns.source_relation = advertisers.source_relation
    {{ dbt_utils.group_by(7) }}
)

select *
from fields
