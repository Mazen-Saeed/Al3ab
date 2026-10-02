using Al3ab.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3ab.Api.Data.Configurations;

public class ReservationConfiguration : IEntityTypeConfiguration<Reservation>
{
    public void Configure(EntityTypeBuilder<Reservation> builder)
    {
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_reservations_time", "ends_at > starts_at");
            // An app customer OR a walk-in, never both.
            t.HasCheckConstraint("ck_reservations_one_customer", "customer_id IS NULL OR walk_in_customer_id IS NULL");
        });
    }
}
