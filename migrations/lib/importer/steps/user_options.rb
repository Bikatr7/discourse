# frozen_string_literal: true

module Migrations::Importer::Steps
  class UserOptions < ::Migrations::Importer::CopyStep
    DEFAULTS = {
      mailing_list_mode: SiteSetting.default_email_mailing_list_mode,
      mailing_list_mode_frequency: SiteSetting.default_email_mailing_list_mode_frequency,
      email_level: SiteSetting.default_email_level,
      email_messages_level: SiteSetting.default_email_messages_level,
      automatically_unpin_topics: SiteSetting.default_topics_automatic_unpin,
      email_previous_replies: SiteSetting.default_email_previous_replies,
      email_in_reply_to: SiteSetting.default_email_in_reply_to,
      enable_quoting: SiteSetting.default_other_enable_quoting,
      enable_smart_lists: SiteSetting.default_other_enable_smart_lists,
      enable_defer: SiteSetting.default_other_enable_defer,
      external_links_in_new_tab: SiteSetting.default_other_external_links_in_new_tab,
      dynamic_favicon: SiteSetting.default_other_dynamic_favicon,
      skip_new_user_tips: SiteSetting.default_other_skip_new_user_tips,
      new_topic_duration_minutes: SiteSetting.default_other_new_topic_duration_minutes,
      auto_track_topics_after_msecs: SiteSetting.default_other_auto_track_topics_after_msecs,
      notification_level_when_replying: SiteSetting.default_other_notification_level_when_replying,
      like_notification_frequency: SiteSetting.default_other_like_notification_frequency,
      email_digests: SiteSetting.default_email_digest_frequency.to_i > 0,
      digest_after_minutes: SiteSetting.default_email_digest_frequency.to_i,
      include_tl0_in_digests: SiteSetting.default_include_tl0_in_digests,
      text_size: SiteSetting.default_text_size,
      title_count_mode: SiteSetting.default_title_count_mode,
      hide_profile: SiteSetting.default_hide_profile,
      hide_presence: SiteSetting.default_hide_presence,
      sidebar_link_to_filtered_list: SiteSetting.default_sidebar_link_to_filtered_list,
      sidebar_show_count_of_new_items: SiteSetting.default_sidebar_show_count_of_new_items,
    }

    depends_on :users

    requires_set :existing_user_ids, "SELECT DISTINCT user_id FROM user_options"

    column_names %i[
                   allow_private_messages
                   auto_track_topics_after_msecs
                   automatically_unpin_topics
                   bookmark_auto_delete_preference
                   color_scheme_id
                   dark_scheme_id
                   default_calendar
                   digest_after_minutes
                   dynamic_favicon
                   email_digests
                   email_in_reply_to
                   email_level
                   email_messages_level
                   email_previous_replies
                   enable_allowed_pm_users
                   enable_defer
                   enable_experimental_sidebar
                   enable_quoting
                   enable_smart_lists
                   external_links_in_new_tab
                   hide_presence
                   hide_profile
                   hide_profile_and_presence
                   homepage_id
                   include_tl0_in_digests
                   last_redirected_to_top_at
                   like_notification_frequency
                   mailing_list_mode
                   mailing_list_mode_frequency
                   new_topic_duration_minutes
                   notification_level_when_replying
                   oldest_search_log_date
                   seen_popups
                   sidebar_link_to_filtered_list
                   sidebar_show_count_of_new_items
                   skip_new_user_tips
                   text_size_key
                   text_size_seq
                   theme_ids
                   theme_key_seq
                   timezone
                   title_count_mode_key
                   topics_unread_when_closed
                   user_id
                   watched_precedence_over_muted
                 ]

    plugin_column_names :chat,
                        %i[
                          chat_email_frequency
                          chat_enabled
                          chat_header_indicator_preference
                          chat_quick_reaction_type
                          chat_quick_reactions_custom
                          chat_send_shortcut
                          chat_separate_sidebar_mode
                          chat_sound
                          dismissed_channel_retention_reminder
                          dismissed_dm_retention_reminder
                          ignore_channel_wide_mention
                          only_chat_push_notifications
                          show_thread_title_prompts
                        ]

    total_rows_query <<~SQL, MappingType::USERS
      SELECT COUNT(*)
      FROM users
           JOIN mapped.ids mapped_users ON users.original_id = mapped_users.original_id AND mapped_users.type = ?
           LEFT JOIN user_options ON users.original_id = user_options.user_id
    SQL

    rows_query <<~SQL, MappingType::USERS
      SELECT mapped_users.discourse_id AS mapped_user_id,
             user_options.*
      FROM users
           JOIN mapped.ids mapped_users ON users.original_id = mapped_users.original_id AND mapped_users.type = ?
           LEFT JOIN user_options ON users.original_id = user_options.user_id
      ORDER BY users.original_id
    SQL

    private

    def transform_row(row)
      return nil if @existing_user_ids.include?(row[:user_id])

      row[:user_id] = row[:mapped_user_id]
      row[:seen_popups] = JSON.parse(row[:seen_popups]) if row[:seen_popups]
      row[:theme_ids] = JSON.parse(row[:theme_ids]) if row[:theme_ids]

      DEFAULTS.each { |key, value| row[key] = value if row[key].nil? }

      super
    end
  end
end
