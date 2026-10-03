using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class ShiftConfiguration : IEntityTypeConfiguration<Shift>
{
    public void Configure(EntityTypeBuilder<Shift> builder)
    {
        // One open shift per venue: only one row per venue may have no closed_at.
        builder.HasIndex(s => s.VenueId).IsUnique().HasFilter("closed_at IS NULL AND deleted_at IS NULL");

        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_shifts_opening_cash", "opening_cash >= 0");
            t.HasCheckConstraint("ck_shifts_time", "closed_at IS NULL OR closed_at >= opened_at");
        });
    }
}
