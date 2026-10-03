namespace Al3b.Api.Data.Entities;

public class Room : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public required string Name { get; set; }

    // Where the room sits in the list (smaller = first). Set by drag and drop in the app.
    public int SortOrder { get; set; }
}
