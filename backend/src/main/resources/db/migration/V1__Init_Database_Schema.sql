-- Module 1: Users & Roles
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(100),
    student_id VARCHAR(20) UNIQUE,
    class_name VARCHAR(50),
    bio TEXT,
    github_link VARCHAR(255),
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_student_id ON users(student_id);

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Module 2 & 7: Sessions, Attendance, Polls
CREATE TABLE club_sessions (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    session_date TIMESTAMPTZ NOT NULL,
    location VARCHAR(255),
    description TEXT
);

CREATE TABLE session_resources (
    id UUID PRIMARY KEY,
    club_session_id UUID NOT NULL REFERENCES club_sessions(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    url VARCHAR(512) NOT NULL
);
CREATE INDEX idx_session_resources_session_id ON session_resources(club_session_id);

CREATE TABLE activities (
    id UUID PRIMARY KEY,
    club_session_id UUID NOT NULL REFERENCES club_sessions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT
);
CREATE INDEX idx_activities_session_id ON activities(club_session_id);

CREATE TABLE attendance (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_session_id UUID NOT NULL REFERENCES club_sessions(id) ON DELETE CASCADE,
    check_in_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    method VARCHAR(10) NOT NULL,
    UNIQUE (user_id, club_session_id)
);
CREATE INDEX idx_attendance_user_id ON attendance(user_id);
CREATE INDEX idx_attendance_session_id ON attendance(club_session_id);

CREATE TABLE polls (
    id UUID PRIMARY KEY,
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    end_time TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_polls_activity_id ON polls(activity_id);

CREATE TABLE poll_options (
    id UUID PRIMARY KEY,
    poll_id UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    text VARCHAR(255) NOT NULL
);
CREATE INDEX idx_poll_options_poll_id ON poll_options(poll_id);

CREATE TABLE votes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    poll_option_id UUID NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE
);
CREATE INDEX idx_votes_user_id ON votes(user_id);
CREATE INDEX idx_votes_poll_option_id ON votes(poll_option_id);


-- Module 3 & 4: Teams & Points
CREATE TABLE seasons (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE teams (
    id UUID PRIMARY KEY,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    project_name VARCHAR(255),
    slogan VARCHAR(512)
);
CREATE INDEX idx_teams_season_id ON teams(season_id);

CREATE TABLE team_members (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    is_leader BOOLEAN DEFAULT FALSE,
    UNIQUE (user_id, team_id)
);
CREATE INDEX idx_team_members_user_id ON team_members(user_id);
CREATE INDEX idx_team_members_team_id ON team_members(team_id);

CREATE TABLE point_entries (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
    points INTEGER NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_point_entries_user_id ON point_entries(user_id);
CREATE INDEX idx_point_entries_team_id ON point_entries(team_id);


-- Module 6: Finance
CREATE TABLE finance_periods (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    deadline DATE NOT NULL
);

CREATE TABLE member_fees (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    finance_period_id UUID NOT NULL REFERENCES finance_periods(id) ON DELETE CASCADE,
    status VARCHAR(10) NOT NULL,
    UNIQUE (user_id, finance_period_id)
);
CREATE INDEX idx_member_fees_user_id ON member_fees(user_id);
CREATE INDEX idx_member_fees_period_id ON member_fees(finance_period_id);

CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    member_fee_id UUID REFERENCES member_fees(id),
    created_by UUID NOT NULL REFERENCES users(id),
    amount NUMERIC(10, 2) NOT NULL,
    description TEXT,
    transaction_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_transactions_created_by ON transactions(created_by);


-- Module 5: Blog
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE posts (
    id UUID PRIMARY KEY,
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    author_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    content TEXT,
    status VARCHAR(10) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);
CREATE INDEX idx_posts_category_id ON posts(category_id);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_slug ON posts(slug);

INSERT INTO roles (name) VALUES ('ROLE_BCN'), ('ROLE_MEMBER'), ('ROLE_TREASURER');