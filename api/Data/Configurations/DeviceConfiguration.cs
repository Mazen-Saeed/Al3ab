using Al3ab.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3ab.Api.Data.Configurations;

public class DeviceConfiguration : IEntityTypeConfiguration<Device>
{
    public void Configure(EntityTypeBuilder<Device> builder)
    {
        // Device -> Venue ("works for"). Configured explicitly because Venue also points
        // to Device (ShopDevice); without this, EF can't tell the two relationships apart.
        builder.HasOne(d => d.Venue).WithMany().HasForeignKey(d => d.VenueId);
    }
}
