using Al3ab.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3ab.Api.Data.Configurations;

public class VenueConfiguration : IEntityTypeConfiguration<Venue>
{
    public void Configure(EntityTypeBuilder<Venue> builder)
    {
        // ~10 cm precision; overrides the numeric(10,2) money default.
        builder.Property(v => v.Latitude).HasPrecision(9, 6);
        builder.Property(v => v.Longitude).HasPrecision(9, 6);
    }
}
