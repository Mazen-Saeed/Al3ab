using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class RemoteCommandConfiguration : IEntityTypeConfiguration<RemoteCommand>
{
    public void Configure(EntityTypeBuilder<RemoteCommand> builder)
    {
        // Postgres jsonb: stored as parsed JSON, can be queried later if needed.
        builder.Property(c => c.Payload).HasColumnType("jsonb");
    }
}
