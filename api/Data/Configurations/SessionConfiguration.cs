using Al3ab.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3ab.Api.Data.Configurations;

public class SessionConfiguration : IEntityTypeConfiguration<Session>
{
    public void Configure(EntityTypeBuilder<Session> builder)
    {
        // A reservation turns into at most one session. NULLs are allowed many times.
        builder.HasIndex(s => s.ReservationId).IsUnique().HasFilter("deleted_at IS NULL");
    }
}
