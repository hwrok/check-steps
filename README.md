# Check Steps

Checks step outcomes, prints statuses, and fails if any step did not succeed.

Use when always running multiple independent steps is desired, versus interdependent, fail-fast scenarios.

## Example Usage

```yaml
- uses: hwrok/check-steps@v1
  if: always()
  with:
    steps: |
      test - unit|${{ steps.test-unit.outcome }}
      test - e2e|${{ steps.test-e2e.outcome }}
      check - format|${{ steps.check-format.outcome }}
      check - eslint|${{ steps.check-eslint.outcome }}
      check - spell|${{ steps.check-spell.outcome }}
```

## Inputs

- `steps` (required): Pipe-delimited list of `label|outcome` pairs, one per line.

## Outputs

- `failed`: `"true"` if any step failed, otherwise `"false"`.

## Notes

- Use `if: always()` to ensure this runs regardless of prior step outcomes. Or, scope to specific steps if desired.
- Non-success outcomes (`failure`, `skipped`, `cancelled`) are treated as failures.
