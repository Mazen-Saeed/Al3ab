using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class SessionUnitConfiguration : IEntityTypeConfiguration<SessionUnit>
{
    public void Configure(EntityTypeBuilder<SessionUnit> builder)
    {
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_sessions_units_time", "ended_at IS NULL OR ended_at >= started_at");
            t.HasCheckConstraint("ck_sessions_units_hourly_price", "hourly_price >= 0");
        });
    }
}
