namespace Al3ab.Api.Data.Entities;

public class PriceCategory : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public required string Name { get; set; }
    public decimal SingleHourlyPrice { get; set; }
    public decimal MultiHourlyPrice { get; set; }
}
