def apply_template!
  gem 'sorcery'

  after_bundle do
    generate("sorcery:install", "remember_me", "reset_password")
  end
end

apply_template!
