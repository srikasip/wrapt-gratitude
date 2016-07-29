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

ActiveRecord::Schema.define(version: 20160729165839) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

end
