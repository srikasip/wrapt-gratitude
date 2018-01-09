# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180107034337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "addresses", force: :cascade do |t|
    t.string   "street1",                         null: false
    t.string   "street2"
    t.string   "street3"
    t.string   "city",                            null: false
    t.string   "state",                           null: false
    t.string   "zip",                             null: false
    t.string   "addressable_type",                null: false
    t.integer  "addressable_id",                  null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "country",          default: "US", null: false
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type", using: :btree
  end

  create_table "charges", force: :cascade do |t|
    t.integer  "customer_order_id"
    t.string   "cart_id",                              null: false
    t.string   "charge_id"
    t.string   "status"
    t.text     "description"
    t.integer  "amount_in_cents"
    t.datetime "payment_made_at"
    t.datetime "declined_at"
    t.string   "idempotency_key"
    t.datetime "idempotency_key_expires_at"
    t.text     "error_message"
    t.jsonb    "metadata"
    t.string   "token"
    t.string   "error_code"
    t.string   "error_param"
    t.string   "decline_code"
    t.string   "error_type"
    t.string   "http_status"
    t.integer  "amount_refunded_in_cents"
    t.datetime "authed_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "bill_zip"
    t.string   "last_four",                  limit: 4
    t.string   "card_type"
    t.jsonb    "refund_stack"
    t.index ["customer_order_id"], name: "index_charges_on_customer_order_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",   null: false
    t.string   "commentable_type", null: false
    t.text     "content",          null: false
    t.integer  "user_id",          null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "conditional_question_options", force: :cascade do |t|
    t.integer  "survey_question_id"
    t.integer  "survey_question_option_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["survey_question_id"], name: "index_conditional_question_options_on_survey_question_id", using: :btree
    t.index ["survey_question_option_id"], name: "index_conditional_question_options_on_survey_question_option_id", using: :btree
  end

  create_table "customer_orders", force: :cascade do |t|
    t.integer  "user_id",                                     null: false
    t.integer  "profile_id",                                  null: false
    t.string   "cart_id",                                     null: false
    t.string   "shipping_choice"
    t.string   "order_number",                                null: false
    t.string   "status",                                      null: false
    t.string   "recipient_name",                              null: false
    t.string   "ship_street1",                                null: false
    t.string   "ship_street2"
    t.string   "ship_street3"
    t.string   "ship_city",                                   null: false
    t.string   "ship_state",                                  null: false
    t.string   "ship_zip",                                    null: false
    t.string   "ship_country",                                null: false
    t.text     "notes"
    t.integer  "subtotal_in_cents",            default: 0,    null: false
    t.integer  "taxes_in_cents",               default: 0,    null: false
    t.integer  "shipping_in_cents",            default: 0,    null: false
    t.integer  "shipping_cost_in_cents",       default: 0,    null: false
    t.integer  "total_to_charge_in_cents",     default: 0,    null: false
    t.date     "created_on",                                  null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "gift_wrapt",                   default: true, null: false
    t.boolean  "include_note",                 default: true, null: false
    t.text     "note_content"
    t.integer  "handling_cost_in_cents",       default: 0,    null: false
    t.integer  "handling_in_cents",            default: 0,    null: false
    t.date     "submitted_on"
    t.integer  "ship_to",                      default: 0
    t.integer  "address_id"
    t.boolean  "shipping_to_giftee",           default: true, null: false
    t.boolean  "need_shipping_calculated",     default: true, null: false
    t.string   "note_envelope_text"
    t.string   "promo_code"
    t.string   "promo_code_mode"
    t.integer  "promo_code_amount"
    t.integer  "promo_delta_in_cents",         default: 0,    null: false
    t.integer  "promo_total_in_cents",         default: 0
    t.integer  "promo_free_subtotal_in_cents", default: 0
    t.index ["address_id"], name: "index_customer_orders_on_address_id", using: :btree
    t.index ["order_number"], name: "index_customer_orders_on_order_number", unique: true, using: :btree
    t.index ["profile_id"], name: "index_customer_orders_on_profile_id", using: :btree
    t.index ["user_id"], name: "index_customer_orders_on_user_id", using: :btree
  end

  create_table "evaluation_recommendations", force: :cascade do |t|
    t.float    "score",                          default: 0.0, null: false
    t.integer  "training_set_evaluation_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "profile_set_survey_response_id"
    t.integer  "gift_id",                                      null: false
    t.integer  "position",                       default: 0
    t.index ["gift_id"], name: "index_evaluation_recommendations_on_gift_id", using: :btree
    t.index ["profile_set_survey_response_id"], name: "eval_rec_survey_response", using: :btree
    t.index ["training_set_evaluation_id"], name: "index_evaluation_recommendations_on_training_set_evaluation_id", using: :btree
  end

  create_table "file_exports", force: :cascade do |t|
    t.string   "asset",      null: false
    t.string   "asset_type", null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type"], name: "index_file_exports_on_asset_type", using: :btree
    t.index ["created_at"], name: "index_file_exports_on_created_at", using: :btree
    t.index ["user_id"], name: "index_file_exports_on_user_id", using: :btree
  end

  create_table "gift_dislikes", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "gift_id"
    t.integer  "reason"
    t.datetime "created_at"
    t.index ["created_at"], name: "index_gift_dislikes_on_created_at", using: :btree
    t.index ["gift_id"], name: "index_gift_dislikes_on_gift_id", using: :btree
    t.index ["profile_id"], name: "index_gift_dislikes_on_profile_id", using: :btree
  end

  create_table "gift_images", force: :cascade do |t|
    t.integer  "gift_id"
    t.string   "image"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "primary",          default: false, null: false
    t.integer  "sort_order",       default: 0,     null: false
    t.boolean  "image_processed",  default: false, null: false
    t.integer  "product_image_id"
    t.string   "type"
    t.integer  "width",            default: 0,     null: false
    t.integer  "height",           default: 0,     null: false
    t.index ["gift_id"], name: "index_gift_images_on_gift_id", using: :btree
    t.index ["primary"], name: "index_gift_images_on_primary", using: :btree
    t.index ["product_image_id"], name: "index_gift_images_on_product_image_id", using: :btree
  end

  create_table "gift_likes", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "reason"
    t.index ["created_at"], name: "index_gift_likes_on_created_at", using: :btree
    t.index ["gift_id"], name: "index_gift_likes_on_gift_id", using: :btree
    t.index ["profile_id"], name: "index_gift_likes_on_profile_id", using: :btree
  end

  create_table "gift_parcels", force: :cascade do |t|
    t.integer  "gift_id",    null: false
    t.integer  "parcel_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_id"], name: "index_gift_parcels_on_gift_id", using: :btree
    t.index ["parcel_id"], name: "index_gift_parcels_on_parcel_id", using: :btree
  end

  create_table "gift_products", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_id"], name: "index_gift_products_on_gift_id", using: :btree
    t.index ["product_id"], name: "index_gift_products_on_product_id", using: :btree
  end

  create_table "gift_question_impacts", force: :cascade do |t|
    t.integer  "training_set_id",                                null: false
    t.integer  "survey_question_id",                             null: false
    t.boolean  "range_impact_direct_correlation", default: true
    t.float    "question_impact",                 default: 0.0,  null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "gift_id",                                        null: false
    t.index ["gift_id"], name: "index_gift_question_impacts_on_gift_id", using: :btree
    t.index ["survey_question_id"], name: "index_gift_question_impacts_on_survey_question_id", using: :btree
    t.index ["training_set_id"], name: "index_gift_question_impacts_on_training_set_id", using: :btree
  end

  create_table "gift_recommendation_notifications", force: :cascade do |t|
    t.integer  "gift_recommendation_set_id"
    t.integer  "user_id"
    t.boolean  "viewed",                     default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "gift_recommendation_sets", force: :cascade do |t|
    t.integer  "profile_id",    null: false
    t.string   "engine_type"
    t.text     "engine_params"
    t.text     "engine_stats"
    t.text     "expert_note"
    t.integer  "expert_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["profile_id"], name: "index_gift_recommendation_sets_on_profile_id", using: :btree
  end

  create_table "gift_recommendations", force: :cascade do |t|
    t.integer  "gift_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "deprecated_profile_id"
    t.float    "score",                 default: 0.0,   null: false
    t.integer  "position",              default: 0
    t.float    "expert_score",          default: 0.0,   null: false
    t.boolean  "removed_by_expert",     default: false, null: false
    t.boolean  "added_by_expert",       default: false, null: false
    t.integer  "recommendation_set_id",                 null: false
    t.index ["deprecated_profile_id"], name: "index_gift_recommendations_on_deprecated_profile_id", using: :btree
    t.index ["gift_id"], name: "index_gift_recommendations_on_gift_id", using: :btree
    t.index ["recommendation_set_id"], name: "index_gift_recommendations_on_recommendation_set_id", using: :btree
  end

  create_table "gift_selections", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "gift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_gift_selections_on_created_at", using: :btree
    t.index ["gift_id"], name: "index_gift_selections_on_gift_id", using: :btree
    t.index ["profile_id"], name: "index_gift_selections_on_profile_id", using: :btree
  end

  create_table "gifts", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "selling_price",                  precision: 10, scale: 2
    t.decimal  "cost",                           precision: 10, scale: 2
    t.string   "wrapt_sku"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.boolean  "calculate_cost_from_products",                            default: true,  null: false
    t.boolean  "calculate_price_from_products",                           default: true,  null: false
    t.integer  "product_category_id"
    t.integer  "product_subcategory_id"
    t.integer  "source_product_id"
    t.boolean  "featured",                                                default: false, null: false
    t.boolean  "calculate_weight_from_products",                          default: true,  null: false
    t.decimal  "weight_in_pounds"
    t.boolean  "available",                                               default: true,  null: false
    t.integer  "insurance_in_dollars"
    t.integer  "tax_code_id"
    t.boolean  "can_be_sold",                                             default: false, null: false
    t.index ["product_category_id"], name: "index_gifts_on_product_category_id", using: :btree
    t.index ["tax_code_id"], name: "index_gifts_on_tax_code_id", using: :btree
    t.index ["wrapt_sku"], name: "index_gifts_on_wrapt_sku", using: :btree
  end

  create_table "invitation_requests", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "invited_user_id"
    t.datetime "invited_at"
    t.string   "how_found"
    t.index ["invited_user_id"], name: "index_invitation_requests_on_invited_user_id", using: :btree
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "orderable_id",                                   null: false
    t.string   "orderable_type",                                 null: false
    t.integer  "order_id",                                       null: false
    t.string   "order_type",                                     null: false
    t.integer  "vendor_id"
    t.boolean  "accounted_for_in_inventory",     default: false, null: false
    t.decimal  "price_per_each_in_dollars"
    t.integer  "quantity"
    t.decimal  "total_price_in_dollars"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.decimal  "taxable_total_price_in_dollars"
    t.index ["vendor_id"], name: "index_line_items_on_vendor_id", using: :btree
  end

  create_table "mvp1b_user_surveys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "age"
    t.string   "gender"
    t.string   "zip"
    t.string   "response_confidence"
    t.string   "recommendation_confidence"
    t.text     "recommendation_comment"
    t.string   "would_use_again"
    t.string   "would_tell_friend"
    t.string   "would_create_wish_list"
    t.string   "would_pay"
    t.text     "pay_comment"
    t.text     "other_services"
    t.text     "mailing_address"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["user_id"], name: "index_mvp1b_user_surveys_on_user_id", using: :btree
  end

  create_table "parcels", force: :cascade do |t|
    t.string   "description",                             null: false
    t.decimal  "length_in_inches",                        null: false
    t.decimal  "width_in_inches",                         null: false
    t.decimal  "height_in_inches",                        null: false
    t.decimal  "weight_in_pounds",                        null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "active",               default: true,     null: false
    t.integer  "case_pack"
    t.string   "color"
    t.string   "source"
    t.string   "stock_number"
    t.string   "usage",                default: "pretty", null: false
    t.string   "code"
    t.string   "shippo_template_name"
  end

  create_table "product_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "lft",                        null: false
    t.integer  "rgt",                        null: false
    t.integer  "parent_id"
    t.integer  "depth",          default: 0, null: false
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "wrapt_sku_code"
    t.index ["lft"], name: "index_product_categories_on_lft", using: :btree
    t.index ["parent_id"], name: "index_product_categories_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_product_categories_on_rgt", using: :btree
    t.index ["wrapt_sku_code"], name: "index_product_categories_on_wrapt_sku_code", using: :btree
  end

  create_table "product_images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "image"
    t.integer  "sort_order",      default: 0,     null: false
    t.boolean  "primary"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "image_processed", default: false, null: false
    t.integer  "width",           default: 0,     null: false
    t.integer  "height",          default: 0,     null: false
    t.index ["primary"], name: "index_product_images_on_primary", using: :btree
    t.index ["product_id"], name: "index_product_images_on_product_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "price",                  precision: 10, scale: 2
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "wrapt_sku"
    t.integer  "vendor_id"
    t.decimal  "vendor_retail_price",    precision: 10, scale: 2
    t.decimal  "wrapt_cost",             precision: 10, scale: 2
    t.integer  "units_available",                                 default: 0, null: false
    t.string   "vendor_sku"
    t.text     "notes"
    t.integer  "source_vendor_id"
    t.integer  "product_category_id"
    t.integer  "product_subcategory_id"
    t.decimal  "weight_in_pounds"
    t.index ["product_category_id"], name: "index_products_on_product_category_id", using: :btree
    t.index ["vendor_id"], name: "index_products_on_vendor_id", using: :btree
    t.index ["wrapt_sku"], name: "index_products_on_wrapt_sku", using: :btree
  end

  create_table "profile_set_survey_responses", force: :cascade do |t|
    t.string   "name"
    t.integer  "profile_set_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["profile_set_id"], name: "index_profile_set_survey_responses_on_profile_set_id", using: :btree
  end

  create_table "profile_sets", force: :cascade do |t|
    t.string   "name"
    t.integer  "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_profile_sets_on_survey_id", using: :btree
  end

  create_table "profile_traits_facets", force: :cascade do |t|
    t.integer  "topic_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_profile_traits_facets_on_topic_id", using: :btree
  end

  create_table "profile_traits_tags", force: :cascade do |t|
    t.integer  "facet_id"
    t.string   "name"
    t.integer  "position",   default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["facet_id"], name: "index_profile_traits_tags_on_facet_id", using: :btree
  end

  create_table "profile_traits_topics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.integer  "owner_id"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "relationship"
    t.boolean  "recommendations_in_progress",        default: false, null: false
    t.datetime "recommendations_generated_at"
    t.string   "recipient_access_token"
    t.boolean  "recipient_reviewed",                 default: false, null: false
    t.datetime "recipient_invited_at"
    t.integer  "gifts_sent",                         default: 0,     null: false
    t.string   "last_name",                          default: ""
    t.datetime "archived_at"
    t.boolean  "has_viewed_initial_recommendations", default: false, null: false
    t.integer  "birthday_day"
    t.integer  "birthday_month"
    t.integer  "birthday_year"
    t.index ["created_at"], name: "index_profiles_on_created_at", using: :btree
    t.index ["recipient_invited_at"], name: "index_profiles_on_recipient_invited_at", using: :btree
  end

  create_table "promo_codes", force: :cascade do |t|
    t.string   "value",                                  null: false
    t.text     "description", default: "no description", null: false
    t.date     "start_date",                             null: false
    t.date     "end_date",                               null: false
    t.integer  "amount",                                 null: false
    t.string   "mode",                                   null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["start_date", "end_date"], name: "index_promo_codes_on_start_date_and_end_date", using: :btree
    t.index ["value"], name: "index_promo_codes_on_value", unique: true, using: :btree
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "vendor_id"
    t.integer  "customer_order_id"
    t.integer  "gift_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "order_number",                                              null: false
    t.date     "created_on",                                                null: false
    t.decimal  "total_due_in_cents"
    t.decimal  "shipping_in_cents"
    t.decimal  "shipping_cost_in_cents"
    t.string   "vendor_token",                                              null: false
    t.string   "vendor_acknowledgement_status"
    t.string   "vendor_acknowledgement_reason"
    t.integer  "handling_cost_in_cents",            default: 0,             null: false
    t.integer  "handling_in_cents",                 default: 0,             null: false
    t.string   "status",                            default: "initialized", null: false
    t.integer  "shipping_parcel_id"
    t.integer  "shipping_carrier_id"
    t.integer  "shipping_service_level_id"
    t.datetime "customer_refunded_at"
    t.integer  "gift_amount_for_customer_in_cents", default: 0,             null: false
    t.integer  "tax_amount_for_customer_in_cents",  default: 0,             null: false
    t.datetime "cancellation_emails_sent_at"
    t.index ["customer_order_id"], name: "index_purchase_orders_on_customer_order_id", using: :btree
    t.index ["gift_id"], name: "index_purchase_orders_on_gift_id", using: :btree
    t.index ["order_number"], name: "index_purchase_orders_on_order_number", unique: true, using: :btree
    t.index ["shipping_carrier_id"], name: "index_purchase_orders_on_shipping_carrier_id", using: :btree
    t.index ["shipping_service_level_id"], name: "index_purchase_orders_on_shipping_service_level_id", using: :btree
    t.index ["vendor_id"], name: "index_purchase_orders_on_vendor_id", using: :btree
    t.index ["vendor_token"], name: "index_purchase_orders_on_vendor_token", unique: true, using: :btree
  end

  create_table "recipient_gift_dislikes", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "reason"
    t.index ["gift_id"], name: "index_recipient_gift_dislikes_on_gift_id", using: :btree
    t.index ["profile_id"], name: "index_recipient_gift_dislikes_on_profile_id", using: :btree
  end

  create_table "recipient_gift_likes", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "gift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "reason"
    t.index ["gift_id"], name: "index_recipient_gift_likes_on_gift_id", using: :btree
    t.index ["profile_id"], name: "index_recipient_gift_likes_on_profile_id", using: :btree
  end

  create_table "recipient_gift_selections", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "gift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_id"], name: "index_recipient_gift_selections_on_gift_id", using: :btree
    t.index ["profile_id"], name: "index_recipient_gift_selections_on_profile_id", using: :btree
  end

  create_table "related_line_items", force: :cascade do |t|
    t.integer  "purchase_order_id",           null: false
    t.integer  "customer_order_id",           null: false
    t.integer  "purchase_order_line_item_id", null: false
    t.integer  "customer_order_line_item_id", null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["customer_order_id"], name: "index_related_line_items_on_customer_order_id", using: :btree
    t.index ["customer_order_line_item_id"], name: "index_related_line_items_on_customer_order_line_item_id", using: :btree
    t.index ["purchase_order_id"], name: "index_related_line_items_on_purchase_order_id", using: :btree
    t.index ["purchase_order_line_item_id"], name: "index_related_line_items_on_purchase_order_line_item_id", using: :btree
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "customer_order_id"
    t.integer  "purchase_order_id"
    t.string   "cart_id",                       null: false
    t.jsonb    "address_from"
    t.jsonb    "address_to"
    t.jsonb    "parcel"
    t.jsonb    "api_response"
    t.boolean  "success"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "insurance_in_dollars"
    t.string   "description_of_what_to_insure"
    t.index ["customer_order_id"], name: "index_shipments_on_customer_order_id", using: :btree
    t.index ["purchase_order_id"], name: "index_shipments_on_purchase_order_id", using: :btree
  end

  create_table "shipping_carriers", force: :cascade do |t|
    t.string   "name",                                null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "shippo_provider_name",                null: false
    t.boolean  "active",               default: true, null: false
    t.index ["name"], name: "index_shipping_carriers_on_name", unique: true, using: :btree
    t.index ["shippo_provider_name"], name: "index_shipping_carriers_on_shippo_provider_name", unique: true, using: :btree
  end

  create_table "shipping_labels", force: :cascade do |t|
    t.integer  "shipment_id"
    t.string   "cart_id",                               null: false
    t.string   "tracking_number"
    t.jsonb    "api_response"
    t.boolean  "success"
    t.text     "url"
    t.string   "shippo_rate_object_id"
    t.text     "error_messages"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "purchase_order_id",                     null: false
    t.integer  "customer_order_id",                     null: false
    t.string   "tracking_url"
    t.datetime "eta"
    t.string   "tracking_status"
    t.datetime "tracking_updated_at"
    t.jsonb    "tracking_payload"
    t.string   "carrier",                               null: false
    t.string   "service_level",                         null: false
    t.date     "shipped_on"
    t.date     "delivered_on"
    t.boolean  "cancelled",             default: false, null: false
    t.jsonb    "refund_api_response"
    t.index ["customer_order_id"], name: "index_shipping_labels_on_customer_order_id", using: :btree
    t.index ["purchase_order_id"], name: "index_shipping_labels_on_purchase_order_id", using: :btree
    t.index ["shipment_id"], name: "index_shipping_labels_on_shipment_id", using: :btree
  end

  create_table "shipping_service_levels", force: :cascade do |t|
    t.integer  "shipping_carrier_id",                null: false
    t.string   "name",                               null: false
    t.string   "shippo_token",                       null: false
    t.integer  "estimated_days",                     null: false
    t.string   "terms",                              null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "active",              default: true, null: false
    t.index ["shipping_carrier_id"], name: "index_shipping_service_levels_on_shipping_carrier_id", using: :btree
    t.index ["shippo_token"], name: "index_shipping_service_levels_on_shippo_token", using: :btree
  end

  create_table "survey_question_options", force: :cascade do |t|
    t.integer  "survey_question_id",               null: false
    t.text     "text"
    t.string   "image"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "sort_order",           default: 0, null: false
    t.string   "type"
    t.text     "explanation"
    t.string   "configuration_string"
    t.index ["survey_question_id"], name: "index_survey_question_options_on_survey_question_id", using: :btree
  end

  create_table "survey_question_response_options", force: :cascade do |t|
    t.integer  "survey_question_response_id", null: false
    t.integer  "survey_question_option_id",   null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["survey_question_option_id"], name: "response_options_on_option_id", using: :btree
    t.index ["survey_question_response_id"], name: "response_options_on_response_id", using: :btree
  end

  create_table "survey_question_responses", force: :cascade do |t|
    t.integer  "survey_response_id",   null: false
    t.integer  "survey_question_id",   null: false
    t.text     "text_response"
    t.float    "range_response"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "name"
    t.text     "other_option_text"
    t.string   "survey_response_type", null: false
    t.datetime "answered_at"
    t.index ["answered_at"], name: "index_survey_question_responses_on_answered_at", using: :btree
    t.index ["survey_question_id"], name: "index_survey_question_responses_on_survey_question_id", using: :btree
    t.index ["survey_response_id"], name: "index_question_response_on_survey_response_id", using: :btree
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "survey_id",                                    null: false
    t.text     "prompt"
    t.integer  "position"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "type"
    t.string   "min_label"
    t.string   "max_label"
    t.string   "mid_label"
    t.integer  "sort_order",                   default: 0,     null: false
    t.boolean  "multiple_option_responses",    default: false, null: false
    t.boolean  "include_other_option",         default: false, null: false
    t.string   "code"
    t.boolean  "use_response_as_name",         default: false, null: false
    t.integer  "conditional_question_id"
    t.integer  "survey_section_id"
    t.boolean  "yes_no_display",               default: false, null: false
    t.text     "placeholder_text"
    t.boolean  "use_response_as_relationship", default: false, null: false
    t.boolean  "price_filter",                 default: false
    t.boolean  "category_filter",              default: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id", using: :btree
    t.index ["survey_section_id"], name: "index_survey_questions_on_survey_section_id", using: :btree
  end

  create_table "survey_response_trait_evaluations", force: :cascade do |t|
    t.integer  "response_id"
    t.integer  "trait_training_set_id"
    t.hstore   "matched_tag_id_counts", default: {}
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "matching_in_progress",  default: false, null: false
    t.index ["matched_tag_id_counts"], name: "index_trait_evaluations_on_matched_tag_id_counts", using: :gin
    t.index ["response_id"], name: "index_survey_response_trait_evaluations_on_response_id", using: :btree
    t.index ["trait_training_set_id"], name: "index_response_trait_evals_on_trait_training_set", using: :btree
  end

  create_table "survey_responses", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "profile_id"
    t.integer  "survey_id"
    t.datetime "completed_at"
    t.index ["completed_at"], name: "index_survey_responses_on_completed_at", using: :btree
    t.index ["profile_id"], name: "index_survey_responses_on_profile_id", using: :btree
    t.index ["survey_id"], name: "index_survey_responses_on_survey_id", using: :btree
  end

  create_table "survey_sections", force: :cascade do |t|
    t.integer  "survey_id"
    t.string   "name"
    t.integer  "sort_order",           default: 0, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "introduction_heading"
    t.text     "introduction_text"
    t.index ["survey_id"], name: "index_survey_sections_on_survey_id", using: :btree
  end

  create_table "surveys", force: :cascade do |t|
    t.string   "title"
    t.boolean  "copy_in_progress", default: false, null: false
    t.boolean  "active"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "test_mode",        default: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "tax_codes", force: :cascade do |t|
    t.boolean  "active",      default: true, null: false
    t.string   "name",                       null: false
    t.text     "description",                null: false
    t.string   "code",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["code"], name: "index_tax_codes_on_code", unique: true, using: :btree
  end

  create_table "tax_transactions", force: :cascade do |t|
    t.string   "cart_id",                                 null: false
    t.integer  "customer_order_id"
    t.string   "transaction_code"
    t.jsonb    "api_request_payload",                     null: false
    t.jsonb    "api_estimation_response"
    t.jsonb    "api_reconcile_response"
    t.boolean  "reconciled",              default: false, null: false
    t.boolean  "success",                 default: false, null: false
    t.decimal  "tax_in_dollars",          default: "0.0", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "is_estimate",             default: false, null: false
    t.jsonb    "api_adjustment_response"
    t.jsonb    "api_capture_response"
    t.boolean  "captured",                default: false, null: false
    t.index ["customer_order_id"], name: "index_tax_transactions_on_customer_order_id", using: :btree
  end

  create_table "training_set_evaluations", force: :cascade do |t|
    t.integer  "training_set_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "recommendations_in_progress", default: false, null: false
    t.index ["training_set_id"], name: "index_training_set_evaluations_on_training_set_id", using: :btree
  end

  create_table "training_set_response_impacts", force: :cascade do |t|
    t.integer  "survey_question_option_id"
    t.float    "impact",                    default: 0.0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "gift_question_impact_id",                 null: false
    t.index ["gift_question_impact_id"], name: "index_training_set_response_impacts_on_gift_question_impact_id", using: :btree
    t.index ["survey_question_option_id"], name: "index_response_impacts_option_id", using: :btree
  end

  create_table "training_sets", force: :cascade do |t|
    t.string   "name"
    t.integer  "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "published"
    t.index ["survey_id"], name: "index_training_sets_on_survey_id", using: :btree
  end

  create_table "trait_response_impacts", force: :cascade do |t|
    t.integer  "trait_training_set_question_id"
    t.integer  "survey_question_option_id"
    t.integer  "range_position"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "profile_traits_tag_id"
    t.index ["profile_traits_tag_id"], name: "index_trait_response_impacts_on_profile_traits_tag_id", using: :btree
    t.index ["survey_question_option_id"], name: "index_trait_response_impacts_on_survey_question_option_id", using: :btree
    t.index ["trait_training_set_question_id"], name: "index_trait_response_impacts_on_trait_training_set_question_id", using: :btree
  end

  create_table "trait_training_set_questions", force: :cascade do |t|
    t.integer  "trait_training_set_id"
    t.integer  "question_id"
    t.integer  "facet_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["facet_id"], name: "index_trait_training_set_questions_on_facet_id", using: :btree
    t.index ["question_id"], name: "index_trait_training_set_questions_on_question_id", using: :btree
    t.index ["trait_training_set_id"], name: "index_trait_training_set_questions_on_trait_training_set_id", using: :btree
  end

  create_table "trait_training_sets", force: :cascade do |t|
    t.string   "name"
    t.integer  "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_trait_training_sets_on_survey_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                                           null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.boolean  "admin",                           default: false, null: false
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.integer  "last_viewed_profile_id"
    t.string   "source"
    t.string   "beta_round"
    t.integer  "recipient_referring_profile_id"
    t.boolean  "unmoderated_testing_platform",    default: false, null: false
    t.datetime "activation_token_generated_at"
    t.boolean  "wants_newsletter",                default: false, null: false
    t.boolean  "terms_of_service_accepted",       default: true,  null: false
    t.index ["activation_token"], name: "index_users_on_activation_token", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["recipient_referring_profile_id"], name: "index_users_on_recipient_referring_profile_id", using: :btree
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
  end

  create_table "vendor_service_levels", force: :cascade do |t|
    t.integer  "vendor_id",                 null: false
    t.integer  "shipping_service_level_id", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["shipping_service_level_id"], name: "index_vendor_service_levels_on_shipping_service_level_id", using: :btree
    t.index ["vendor_id", "shipping_service_level_id"], name: "vsl_vendor_id_ssl_id_unq_idx", unique: true, using: :btree
    t.index ["vendor_id"], name: "index_vendor_service_levels_on_vendor_id", using: :btree
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "name"
    t.text     "defunct_address"
    t.string   "contact_name"
    t.string   "email"
    t.string   "phone"
    t.text     "notes"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "wrapt_sku_code"
    t.string   "street1",                        default: "unknown", null: false
    t.string   "city",                           default: "unknown", null: false
    t.string   "state",                          default: "unknown", null: false
    t.string   "zip",                            default: "unknown", null: false
    t.string   "country",                        default: "unknown", null: false
    t.string   "street2"
    t.string   "street3"
    t.integer  "purchase_order_markup_in_cents", default: 800,       null: false
    t.index ["wrapt_sku_code"], name: "index_vendors_on_wrapt_sku_code", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.text     "object_changes"
    t.string   "cart_id"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "charges", "customer_orders"
  add_foreign_key "comments", "users"
  add_foreign_key "conditional_question_options", "survey_question_options"
  add_foreign_key "conditional_question_options", "survey_questions"
  add_foreign_key "customer_orders", "profiles"
  add_foreign_key "customer_orders", "users"
  add_foreign_key "file_exports", "users"
  add_foreign_key "gift_dislikes", "gifts"
  add_foreign_key "gift_dislikes", "profiles"
  add_foreign_key "gift_images", "gifts"
  add_foreign_key "gift_images", "product_images"
  add_foreign_key "gift_likes", "gifts"
  add_foreign_key "gift_likes", "profiles"
  add_foreign_key "gift_parcels", "gifts"
  add_foreign_key "gift_parcels", "parcels"
  add_foreign_key "gift_products", "gifts"
  add_foreign_key "gift_products", "products"
  add_foreign_key "gift_recommendations", "gifts"
  add_foreign_key "gift_recommendations", "profiles", column: "deprecated_profile_id"
  add_foreign_key "gift_selections", "gifts"
  add_foreign_key "gift_selections", "profiles"
  add_foreign_key "gifts", "product_categories"
  add_foreign_key "gifts", "tax_codes"
  add_foreign_key "line_items", "vendors"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "product_categories"
  add_foreign_key "products", "vendors"
  add_foreign_key "profile_set_survey_responses", "profile_sets"
  add_foreign_key "profile_sets", "surveys"
  add_foreign_key "profile_traits_facets", "profile_traits_topics", column: "topic_id"
  add_foreign_key "profile_traits_tags", "profile_traits_facets", column: "facet_id"
  add_foreign_key "profiles", "users", column: "owner_id"
  add_foreign_key "purchase_orders", "customer_orders"
  add_foreign_key "purchase_orders", "gifts"
  add_foreign_key "purchase_orders", "shipping_carriers"
  add_foreign_key "purchase_orders", "shipping_service_levels"
  add_foreign_key "purchase_orders", "vendors"
  add_foreign_key "related_line_items", "customer_orders"
  add_foreign_key "related_line_items", "line_items", column: "customer_order_line_item_id", name: "co_line_item_fk"
  add_foreign_key "related_line_items", "line_items", column: "purchase_order_line_item_id", name: "po_line_item_fk"
  add_foreign_key "related_line_items", "purchase_orders"
  add_foreign_key "shipments", "customer_orders"
  add_foreign_key "shipments", "purchase_orders"
  add_foreign_key "shipping_labels", "customer_orders"
  add_foreign_key "shipping_labels", "purchase_orders"
  add_foreign_key "shipping_labels", "shipments"
  add_foreign_key "shipping_service_levels", "shipping_carriers"
  add_foreign_key "survey_question_response_options", "survey_question_options"
  add_foreign_key "survey_question_response_options", "survey_question_responses"
  add_foreign_key "survey_question_responses", "survey_questions"
  add_foreign_key "survey_responses", "profiles"
  add_foreign_key "survey_responses", "surveys"
  add_foreign_key "survey_sections", "surveys"
  add_foreign_key "tax_transactions", "customer_orders"
  add_foreign_key "training_set_evaluations", "training_sets"
  add_foreign_key "trait_response_impacts", "profile_traits_tags"
  add_foreign_key "trait_response_impacts", "survey_question_options"
  add_foreign_key "trait_response_impacts", "trait_training_set_questions"
  add_foreign_key "trait_training_set_questions", "survey_questions", column: "question_id"
  add_foreign_key "trait_training_set_questions", "trait_training_sets"
  add_foreign_key "trait_training_sets", "surveys"
  add_foreign_key "vendor_service_levels", "shipping_service_levels"
  add_foreign_key "vendor_service_levels", "vendors"
end
