/// Test data: every record it writes has an ID starting with [demoIdPrefix],
/// so it can be told apart from the household's own and removed alone.
const demoIdPrefix = 'demo_';

/// Whether [id] is test data or derived from it - a recurring bill's
/// movement (`recurring_demo_…`) or a notice about a demo record
/// (`debt_due_demo_…`) carry the demo ID inside theirs.
bool isDemoId(String id) => id.contains(demoIdPrefix);
