class CreateInitialSchema < ActiveRecord::Migration[5.0]
  def change
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"

    create_table "aliases", force: :cascade do |t|
      t.uuid   "prisoner_id"
      t.string "title"
      t.string "given_name"
      t.string "middle_names"
      t.string "surname"
      t.string "suffix"
      t.string "gender"
      t.string "ethnicity_code"
      t.date   "date_of_birth"
    end

    add_index "aliases", ["given_name"], name: "index_aliases_on_given_name", using: :btree
    add_index "aliases", ["prisoner_id"], name: "index_aliases_on_prisoner_id", using: :btree
    add_index "aliases", ["surname"], name: "index_aliases_on_surname", using: :btree

    create_table "imports", force: :cascade do |t|
      t.string   "file"
      t.boolean  "successful", default: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "oauth_access_grants", force: :cascade do |t|
      t.integer  "resource_owner_id", null: false
      t.integer  "application_id",    null: false
      t.string   "token",             null: false
      t.integer  "expires_in",        null: false
      t.text     "redirect_uri",      null: false
      t.datetime "created_at",        null: false
      t.datetime "revoked_at"
      t.string   "scopes"
    end

    add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

    create_table "oauth_access_tokens", force: :cascade do |t|
      t.integer  "resource_owner_id"
      t.integer  "application_id"
      t.string   "token",             null: false
      t.string   "refresh_token"
      t.integer  "expires_in"
      t.datetime "revoked_at"
      t.datetime "created_at",        null: false
      t.string   "scopes"
    end

    add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

    create_table "oauth_applications", force: :cascade do |t|
      t.string   "name",                      null: false
      t.string   "uid",                       null: false
      t.string   "secret",                    null: false
      t.text     "redirect_uri",              null: false
      t.string   "scopes",       default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

    create_table "prisoners", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
      t.string   "noms_id"
      t.string   "given_name"
      t.string   "middle_names"
      t.string   "surname"
      t.string   "title"
      t.string   "suffix"
      t.date     "date_of_birth"
      t.string   "gender"
      t.string   "pnc_number"
      t.string   "nationality_code"
      t.string   "second_nationality_code"
      t.string   "ethnicity_code"
      t.string   "sexual_orientation_code"
      t.string   "cro_number"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "prisoners", ["noms_id"], name: "index_prisoners_on_noms_id", using: :btree
    add_index "prisoners", ["pnc_number"], name: "index_prisoners_on_pnc_number", using: :btree

    create_table "uploads", force: :cascade do |t|
      t.string   "md5"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "uploads", ["md5"], name: "index_uploads_on_md5", using: :btree

    create_table "users", force: :cascade do |t|
      t.string   "email",                  default: "", null: false
      t.string   "encrypted_password",     default: "", null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
      t.string   "role"
    end

    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    add_index "users", ["role"], name: "index_users_on_role", using: :btree

    create_table "versions", force: :cascade do |t|
      t.string   "item_type",  null: false
      t.integer  "item_id",    null: false
      t.string   "event",      null: false
      t.string   "whodunnit"
      t.text     "object"
      t.datetime "created_at"
    end

    add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end
end
