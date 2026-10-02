using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class VenueConfiguration : IEntityTypeConfiguration<Venue>
{
    public void Configure(EntityTypeBuilder<Venue> builder)
    {
        // ~10 cm precision; overrides the numeric(10,2) money default.
        builder.Property(v => v.Latitude).HasPrecision(9, 6);
        builder.Property(v => v.Longitude).HasPrecision(9, 6);

        // Venue -> its shop device. A device can run at most one venue.
        builder.HasOne(v => v.ShopDevice).WithMany().HasForeignKey(v => v.ShopDeviceId);
        builder.HasIndex(v => v.ShopDeviceId).IsUnique().HasFilter("deleted_at IS NULL");
    }
}
