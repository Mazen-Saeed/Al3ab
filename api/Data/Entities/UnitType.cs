namespace Al3ab.Api.Data.Entities;

// Global list (PS4, PS5, ...). Managed by the backend only, so it doesn't need sync columns.
public class UnitType
{
    public Guid Id { get; set; } = Guid.CreateVersion7();
    public required string Name { get; set; }
}
