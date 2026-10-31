.PHONY: doctor docs-check next-ticket check check-app check-server check-all

doctor:
	@bash scripts/doctor.sh

docs-check:
	@bash scripts/docs_check.sh

next-ticket:
	@bash scripts/next_ticket.sh

check-app:
	@cd app && flutter analyze && flutter test test/l10n/arb_keys_test.dart test/core/localization/locale_view_model_test.dart test/features/profile/profile_edit_view_model_test.dart

check-server:
	@cd server && node --test test/profile.edit_and_private.test.js test/skills.custom_repo_and_confidence.test.js

check: docs-check check-app check-server
	@echo "All spec and unit checks passed successfully!"

check-all: doctor docs-check check-app check-server
	@echo "Full system check completed cleanly!"

