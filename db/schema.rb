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

ActiveRecord::Schema.define(version: 20160913180549) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "evaluation_recommendations", force: :cascade do |t|
    t.integer  "product_id"
    t.float    "score",                          default: 0.0, null: false
    t.integer  "training_set_evaluation_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "profile_set_survey_response_id"
    t.index ["product_id"], name: "index_evaluation_recommendations_on_product_id", using: :btree
    t.index ["profile_set_survey_response_id"], name: "eval_rec_survey_response", using: :btree
    t.index ["training_set_evaluation_id"], name: "index_evaluation_recommendations_on_training_set_evaluation_id", using: :btree
  end

  create_table "gift_products", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gift_id"], name: "index_gift_products_on_gift_id", using: :btree
    t.index ["product_id"], name: "index_gift_products_on_product_id", using: :btree
  end

  create_table "gifts", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "selling_price",     precision: 10, scale: 2
    t.decimal  "cost",              precision: 10, scale: 2
    t.string   "wrapt_sku"
    t.date     "date_available"
    t.date     "date_discontinued"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
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
    t.index ["lft"], name: "index_product_categories_on_lft", using: :btree
    t.index ["parent_id"], name: "index_product_categories_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_product_categories_on_rgt", using: :btree
  end

  create_table "product_categories_products", force: :cascade do |t|
    t.integer  "product_category_id"
    t.integer  "product_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["product_category_id"], name: "index_product_categories_products_on_product_category_id", using: :btree
    t.index ["product_id"], name: "index_product_categories_products_on_product_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "price",       precision: 10, scale: 2
    t.boolean  "public"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "image"
    t.string   "wrapt_sku"
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

  create_table "survey_question_options", force: :cascade do |t|
    t.integer  "survey_question_id",             null: false
    t.text     "text"
    t.string   "image"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "sort_order",         default: 0, null: false
    t.index ["survey_question_id"], name: "index_survey_question_options_on_survey_question_id", using: :btree
  end

  create_table "survey_question_responses", force: :cascade do |t|
    t.integer  "profile_set_survey_response_id", null: false
    t.integer  "survey_question_id",             null: false
    t.text     "text_response"
    t.integer  "survey_question_option_id"
    t.float    "range_response"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "name"
    t.index ["profile_set_survey_response_id"], name: "index_question_response_on_survey_response_id", using: :btree
    t.index ["survey_question_id"], name: "index_survey_question_responses_on_survey_question_id", using: :btree
    t.index ["survey_question_option_id"], name: "index_survey_question_responses_on_survey_question_option_id", using: :btree
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "survey_id",              null: false
    t.text     "prompt"
    t.integer  "position"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "type"
    t.string   "min_label"
    t.string   "max_label"
    t.string   "mid_label"
    t.integer  "sort_order", default: 0, null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id", using: :btree
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
  end

  create_table "training_set_evaluations", force: :cascade do |t|
    t.integer  "training_set_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["training_set_id"], name: "index_training_set_evaluations_on_training_set_id", using: :btree
  end

  create_table "training_set_product_questions", force: :cascade do |t|
    t.integer  "training_set_id",                                null: false
    t.integer  "product_id",                                     null: false
    t.integer  "survey_question_id",                             null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "range_impact_direct_correlation", default: true, null: false
    t.float    "question_impact",                 default: 0.0,  null: false
    t.index ["product_id"], name: "index_training_set_product_questions_on_product_id", using: :btree
    t.index ["survey_question_id"], name: "index_training_set_product_questions_on_survey_question_id", using: :btree
    t.index ["training_set_id"], name: "index_training_set_product_questions_on_training_set_id", using: :btree
  end

  create_table "training_set_response_impacts", force: :cascade do |t|
    t.integer  "training_set_product_question_id"
    t.integer  "survey_question_option_id"
    t.float    "impact",                           default: 0.0, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.index ["survey_question_option_id"], name: "index_response_impacts_option_id", using: :btree
    t.index ["training_set_product_question_id"], name: "index_response_impacts_pq_id", using: :btree
  end

  create_table "training_sets", force: :cascade do |t|
    t.string   "name"
    t.integer  "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_training_sets_on_survey_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "evaluation_recommendations", "products"
  add_foreign_key "evaluation_recommendations", "profile_set_survey_responses"
  add_foreign_key "evaluation_recommendations", "training_set_evaluations"
  add_foreign_key "gift_products", "gifts"
  add_foreign_key "gift_products", "products"
  add_foreign_key "profile_set_survey_responses", "profile_sets"
  add_foreign_key "profile_sets", "surveys"
  add_foreign_key "survey_question_responses", "profile_set_survey_responses"
  add_foreign_key "survey_question_responses", "survey_question_options"
  add_foreign_key "survey_question_responses", "survey_questions"
  add_foreign_key "training_set_evaluations", "training_sets"
  add_foreign_key "training_set_product_questions", "products"
  add_foreign_key "training_set_product_questions", "survey_questions"
  add_foreign_key "training_set_product_questions", "training_sets"
end
