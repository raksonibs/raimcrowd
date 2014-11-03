# This migration comes from neighborly_admin (originally 20141005191509)
class CreateNeighborlyAdminStatistics < ActiveRecord::Migration
  def up
    execute <<-SQL
       CREATE OR REPLACE VIEW neighborly_admin_statistics AS
       SELECT
        ( SELECT count(*) AS count FROM users) AS total_users,
        ( SELECT count(*) AS count FROM users WHERE profile_type::text = 'organization'::text ) AS total_organization_users,
        ( SELECT count(*) AS count FROM users WHERE profile_type::text = 'personal'::text ) AS total_personal_users,
        ( SELECT count(*) AS count FROM users WHERE profile_type::text = 'channel'::text ) AS total_channel_users,
        ( SELECT COUNT(*) FROM ( SELECT DISTINCT address_city, address_state FROM projects ) AS count ) AS total_communities,
        contributions_totals.total_contributions,
        contributions_totals.total_contributors,
        contributions_totals.total_contributed,
        projects_totals.total_projects,
        projects_totals.total_projects_success,
        projects_totals.total_projects_online,
        projects_totals.total_projects_draft,
        projects_totals.total_projects_soon
       FROM ( SELECT count(*) AS total_contributions,
                count(DISTINCT contributions.user_id) AS total_contributors,
                sum(contributions.value) AS total_contributed
               FROM contributions
              WHERE contributions.state::text <> ALL (ARRAY['waiting_confirmation'::character varying::text, 'pending'::character varying::text, 'canceled'::character varying::text, 'deleted'])) contributions_totals,
        ( SELECT count(*) AS total_projects,
                count(
                    CASE
                        WHEN projects.state::text = 'draft'::text THEN 1
                        ELSE NULL::integer
                    END) AS total_projects_draft,
              count(
                    CASE
                        WHEN projects.state::text = 'soon'::text THEN 1
                        ELSE NULL::integer
                    END) AS total_projects_soon,
                count(
                    CASE
                        WHEN projects.state::text = 'successful'::text THEN 1
                        ELSE NULL::integer
                    END) AS total_projects_success,
                count(
                    CASE
                        WHEN projects.state::text = 'online'::text THEN 1
                        ELSE NULL::integer
                    END) AS total_projects_online
               FROM projects
              WHERE projects.state::text <> ALL (ARRAY['deleted'::character varying::text, 'rejected'::character varying::text])) projects_totals;
    SQL
  end

  def down
    execute <<-SQL
       DROP VIEW neighborly_admin_statistics;
    SQL
  end
end
