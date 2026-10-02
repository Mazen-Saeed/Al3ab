using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class StaffConfiguration : IEntityTypeConfiguration<Staff>
{
    public void Configure(EntityTypeBuilder<Staff> builder)
    {
        // Phone is the login. Unique among non-deleted rows, so a deleted account doesn't block its phone forever.
        builder.HasIndex(s => s.Phone).IsUnique().HasFilter("deleted_at IS NULL");
    }
}
