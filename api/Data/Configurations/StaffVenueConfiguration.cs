using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class StaffVenueConfiguration : IEntityTypeConfiguration<StaffVenue>
{
    public void Configure(EntityTypeBuilder<StaffVenue> builder)
    {
        // A staff member has one role per venue.
        builder.HasIndex(sv => new { sv.StaffId, sv.VenueId }).IsUnique().HasFilter("deleted_at IS NULL");
    }
}
