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

ActiveRecord::Schema.define(version: 20160803171703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  end

  create_table "survey_question_options", force: :cascade do |t|
    t.integer  "survey_question_id", null: false
    t.text     "text"
    t.string   "image"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["survey_question_id"], name: "index_survey_question_options_on_survey_question_id", using: :btree
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer  "survey_id",  null: false
    t.text     "prompt"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id", using: :btree
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
  end

  create_table "training_set_product_questions", force: :cascade do |t|
    t.integer  "training_set_id",    null: false
    t.integer  "product_id",         null: false
    t.integer  "survey_question_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["product_id"], name: "index_training_set_product_questions_on_product_id", using: :btree
    t.index ["survey_question_id"], name: "index_training_set_product_questions_on_survey_question_id", using: :btree
    t.index ["training_set_id"], name: "index_training_set_product_questions_on_training_set_id", using: :btree
  end

  create_table "training_set_response_impacts", force: :cascade do |t|
    t.integer  "training_set_product_question_id"
    t.integer  "survey_question_option_id"
    t.integer  "impact",                           default: 0, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
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

  add_foreign_key "training_set_product_questions", "products"
  add_foreign_key "training_set_product_questions", "survey_questions"
  add_foreign_key "training_set_product_questions", "training_sets"
end
