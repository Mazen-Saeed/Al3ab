namespace Al3b.Api.Data.Entities;

// Base class for every table that syncs between the shop PC and the backend.
public abstract class SyncedEntity
{
    // UUID v7: created on the device that makes the row, time-ordered so Postgres indexes stay fast.
    public Guid Id { get; set; } = Guid.CreateVersion7();

    // Set on every create/edit. Sync sends rows whose UpdatedAt is newer than the last sync.
    // Not set automatically on save: rows coming from the shop PC must keep the PC's timestamp (last write wins).
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Who made the last change (including a soft delete). Not full history, just the latest change.
    // Plain column, no foreign key: keeps 17 extra FKs out of the model.
    public Guid? UpdatedByStaffId { get; set; }

    // Soft delete: set this instead of deleting the row, so the delete itself can sync.
    public DateTime? DeletedAt { get; set; }
}
