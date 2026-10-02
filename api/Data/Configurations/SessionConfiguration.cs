using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class SessionConfiguration : IEntityTypeConfiguration<Session>
{
    public void Configure(EntityTypeBuilder<Session> builder)
    {
        // A reservation turns into at most one session. NULLs are allowed many times.
        builder.HasIndex(s => s.ReservationId).IsUnique().HasFilter("deleted_at IS NULL");

        // An app customer OR a walk-in, never both.
        builder.ToTable(t => t.HasCheckConstraint("ck_sessions_one_customer", "customer_id IS NULL OR walk_in_customer_id IS NULL"));
    }
}
