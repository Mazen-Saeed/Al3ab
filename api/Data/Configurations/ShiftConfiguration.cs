using Al3ab.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3ab.Api.Data.Configurations;

public class ShiftConfiguration : IEntityTypeConfiguration<Shift>
{
    public void Configure(EntityTypeBuilder<Shift> builder)
    {
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_shifts_opening_cash", "opening_cash >= 0");
            t.HasCheckConstraint("ck_shifts_time", "closed_at IS NULL OR closed_at >= opened_at");
        });
    }
}
