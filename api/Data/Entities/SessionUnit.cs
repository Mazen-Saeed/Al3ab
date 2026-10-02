using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

// One device used during a session. A session can switch device or mode, giving several rows.
public class SessionUnit : SyncedEntity
{
    public Guid SessionId { get; set; }
    public Session Session { get; set; } = null!;

    public Guid UnitId { get; set; }
    public Unit Unit { get; set; } = null!;

    public DateTime StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public SessionMode Mode { get; set; }

    // Snapshot of the price at the time: menu changes don't rewrite old sessions.
    public decimal HourlyPrice { get; set; }
}
