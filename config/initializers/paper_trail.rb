# PaperTrail configuration

# Use JSON serializer for better compatibility with changeset tracking
PaperTrail.serializer = PaperTrail::Serializers::JSON

# For test environment: Use save_changes! option to save versions immediately
# instead of after_commit, which is necessary for transactional fixtures
if Rails.env.test?
  PaperTrail.config.has_paper_trail_defaults = {
    on: %i[create update destroy],
    save_changes: true
  }
end
